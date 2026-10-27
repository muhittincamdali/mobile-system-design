import MobileSystemDesign
import SwiftUI

/// One replica of a shared note title: a device with its own, possibly wrong, clock.
struct Replica {
    let name: String
    var clockSkew: TimeInterval
    var clock: HybridLogicalClock
    var title: LWWRegister<String>
    var draft: String

    init(name: String, clockSkew: TimeInterval, initial: LWWRegister<String>) {
        self.name = name
        self.clockSkew = clockSkew
        self.clock = HybridLogicalClock(node: name, maximumDrift: .seconds(60))
        self.title = initial
        self.draft = initial.value
    }
}

@MainActor
@Observable
final class SyncModel {
    private(set) var phone: Replica
    private(set) var tablet: Replica
    private(set) var log: [String] = []
    var phoneDraft: String {
        get { phone.draft }
        set { phone.draft = newValue }
    }
    var tabletDraft: String {
        get { tablet.draft }
        set { tablet.draft = newValue }
    }
    var tabletSkew: Double {
        get { tablet.clockSkew }
        set { tablet.clockSkew = newValue }
    }

    /// The lab's wall clock: it starts at a fixed date and moves one second per action, so the
    /// timestamps on screen are the same on every run.
    private var wallClock = Date(timeIntervalSince1970: 1_793_000_000)

    init() {
        let initial = LWWRegister("Groceries", timestamp: HybridTimestamp(milliseconds: 0, counter: 0, node: "seed"))
        phone = Replica(name: "phone", clockSkew: 0, initial: initial)
        tablet = Replica(name: "tablet", clockSkew: -45, initial: initial)
    }

    func savePhone() { save(&phone) }
    func saveTablet() { save(&tablet) }

    /// Each device sends its title to the other; each merges what it receives.
    func sync() {
        wallClock.addTimeInterval(1)
        let phoneCopy = phone.title
        let tabletCopy = tablet.title
        receive(tabletCopy, into: &phone)
        receive(phoneCopy, into: &tablet)
        if phone.title == tablet.title {
            log.insert("Synced: both show “\(phone.title.value)”", at: 0)
        }
    }

    private func save(_ replica: inout Replica) {
        wallClock.addTimeInterval(1)
        do {
            let stamp = try replica.clock.tick(physicalTime: wallClock.addingTimeInterval(replica.clockSkew))
            replica.title.set(replica.draft, timestamp: stamp)
            log.insert("\(replica.name) saved “\(replica.draft)” at \(stamp)", at: 0)
        } catch {
            log.insert("\(replica.name): clock error", at: 0)
        }
    }

    private func receive(_ remote: LWWRegister<String>, into replica: inout Replica) {
        do {
            _ = try replica.clock.receive(remote.timestamp, physicalTime: wallClock.addingTimeInterval(replica.clockSkew))
            if replica.title.merge(remote) {
                replica.draft = replica.title.value
            }
        } catch HybridLogicalClock.ClockError.driftExceeded(let stamp, _) {
            log.insert("\(replica.name) rejected \(stamp): too far ahead of its clock", at: 0)
        } catch {
            log.insert("\(replica.name): clock error", at: 0)
        }
    }
}

struct SyncLabView: View {
    @State private var model = SyncModel()
    var seeded = false

    var body: some View {
        Form {
            Section {
                replicaEditor(name: "Phone", text: $model.phoneDraft, replica: model.phone, save: model.savePhone)
                replicaEditor(name: "Tablet", text: $model.tabletDraft, replica: model.tablet, save: model.saveTablet)
                VStack(alignment: .leading) {
                    Text("Tablet clock: \(Int(model.tabletSkew)) s").font(.subheadline)
                    Slider(value: $model.tabletSkew, in: -120...120, step: 15) {
                        Text("Tablet clock offset")
                    }
                }
                Button("Sync both devices", action: model.sync)
                    .buttonStyle(.borderedProminent)
            } header: {
                Text("Hybrid logical clock · Last-writer-wins")
            } footer: {
                Text("Save on the phone, sync, then save on the tablet and sync again: the tablet's edit wins on both devices although its clock is 45 s behind, because its clock has seen the phone's edit. Edits saved without a sync in between are concurrent and the later timestamp wins. Set the tablet more than 60 s ahead and the phone rejects its timestamps.")
            }

            Section("Events, newest first") {
                if model.log.isEmpty {
                    Text("No events yet").foregroundStyle(.secondary)
                }
                ForEach(Array(model.log.enumerated()), id: \.offset) { _, line in
                    Text(line).font(.footnote.monospaced())
                }
            }
        }
        .navigationTitle("Sync")
        .onAppear {
            if seeded, model.log.isEmpty { model.seedForScreenshot() }
        }
    }

    private func replicaEditor(name: String, text: Binding<String>, replica: Replica, save: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                TextField("\(name) title", text: text)
                    .textFieldStyle(.roundedBorder)
                Button("Save", action: save)
            }
            Text("\(name): “\(replica.title.value)” · \(replica.title.timestamp.description)")
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
    }
}

extension SyncModel {
    /// An edit on the phone, a sync, a later edit on the tablet (whose clock is behind) and a
    /// second sync, for the README screenshot.
    func seedForScreenshot() {
        phoneDraft = "Groceries for Sunday"
        savePhone()
        sync()
        tabletDraft = "Weekend groceries"
        saveTablet()
        sync()
    }
}
