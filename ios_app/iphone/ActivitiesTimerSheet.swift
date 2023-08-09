import SwiftUI
import shared

extension TimetoSheet {

    func showActivitiesTimerSheet(
            isPresented: Binding<Bool>,
            timerContext: ActivityTimerSheetVM.TimerContext?,
            selectedActivity: ActivityModel?,
            onStart: @escaping () -> Void
    ) {
        items.append(
                TimetoSheet__Item(
                        isPresented: isPresented,
                        content: {
                            AnyView(
                                    ActivitiesTimerSheet(
                                            isPresented: isPresented,
                                            timerContext: timerContext,
                                            selectedActivity: selectedActivity
                                    ) {
                                        isPresented.wrappedValue = false
                                        onStart()
                                    }
                                            .cornerRadius(10, onTop: true, onBottom: false)
                            )
                        }
                )
        )
    }
}

private let bgColor = c.sheetBg
private let listItemHeight = 46.0
private let topContentPadding = 2.0
private let bottomContentPadding = 28.0

private let activityItemEmojiWidth = 30.0
private let activityItemEmojiHPadding = 8.0
private let activityItemPaddingStart = activityItemEmojiWidth + (activityItemEmojiHPadding * 2)

private let secondaryFontSize = 15.0
private let secondaryFontWeight: Font.Weight = .light
private let timerHintHPadding = 5.0
private let listEngPadding = 8.0

private let myButtonStyle = MyButtonStyle()

private struct ActivitiesTimerSheet: View {

    @State private var vm: ActivitiesTimerSheetVM

    @State private var sheetActivity: ActivityModel?
    @Binding private var isPresented: Bool

    @State private var isChartPresented = false
    @State private var isHistoryPresented = false
    @State private var isEditActivitiesPresented = false

    private let timerContext: ActivityTimerSheetVM.TimerContext?
    private let onStart: () -> Void

    init(
            isPresented: Binding<Bool>,
            timerContext: ActivityTimerSheetVM.TimerContext?,
            selectedActivity: ActivityModel?,
            onStart: @escaping () -> Void
    ) {
        _isPresented = isPresented
        self.timerContext = timerContext
        self.onStart = onStart

        _vm = State(initialValue: ActivitiesTimerSheetVM(timerContext: timerContext))
        _sheetActivity = State(initialValue: selectedActivity)
    }

    var body: some View {

        // todo If inside VMView twitch on open sheet
        let contentHeight = (listItemHeight * DI.activitiesSorted.count.toDouble()) +
                            listItemHeight + // Buttons
                            topContentPadding +
                            bottomContentPadding

        let sheetHeight = max(
                ActivityTimerSheet.RECOMMENDED_HEIGHT, // Invalid UI if height too small
                contentHeight // Do not be afraid of too much height because the native sheet will cut
        )

        VMView(vm: vm) { state in

            ZStack {

                if let sheetActivity = sheetActivity {
                    ActivityTimerSheet(
                            activity: sheetActivity,
                            isPresented: $isPresented,
                            timerContext: timerContext,
                            onStart: {
                                onStart()
                            }
                    )
                } else {

                    ScrollView {

                        VStack {

                            Padding(vertical: topContentPadding)

                            ForEach(state.allActivities, id: \.activity.id) { activityUI in

                                Button(
                                        action: {
                                            sheetActivity = activityUI.activity
                                        },
                                        label: {

                                            ZStack(alignment: .bottom) { // .bottom for divider

                                                HStack {

                                                    Text(activityUI.activity.emoji)
                                                            .frame(width: activityItemEmojiWidth)
                                                            .padding(.horizontal, activityItemEmojiHPadding)
                                                            .font(.system(size: 22))

                                                    Text(activityUI.listText)
                                                            .foregroundColor(.primary)
                                                            .truncationMode(.tail)
                                                            .lineLimit(1)

                                                    Spacer()

                                                    ForEach(activityUI.timerHints, id: \.seconds) { hintUI in
                                                        let isPrimary = hintUI.isPrimary
                                                        Button(
                                                                action: {
                                                                    hintUI.startInterval {
                                                                        onStart()
                                                                    }
                                                                },
                                                                label: {
                                                                    Text(hintUI.text)
                                                                            .font(.system(size: isPrimary ? 14 : secondaryFontSize, weight: isPrimary ? .medium : secondaryFontWeight))
                                                                            .foregroundColor(isPrimary ? .white : .blue)
                                                                            .padding(.horizontal, isPrimary ? 6 : timerHintHPadding)
                                                                            .padding(.vertical, 4)
                                                                            .background(isPrimary ? .blue : .clear)
                                                                            .cornerRadius(99)
                                                                }
                                                        )
                                                                .buttonStyle(.borderless)
                                                    }
                                                }
                                                        .padding(.trailing, listEngPadding)
                                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

                                                if state.allActivities.last != activityUI {
                                                    DividerSheetBg()
                                                            .padding(.leading, activityItemPaddingStart)
                                                }
                                            }
                                                    .frame(alignment: .bottom)
                                        }
                                )
                            }
                                    .buttonStyle(myButtonStyle)

                            HStack {

                                ChartHistoryButton(text: "Chart", iconName: "chart.pie", iconSize: 17) {
                                    isChartPresented = true
                                }
                                        .padding(.leading, 16)
                                        .padding(.trailing, 10)
                                        .sheetEnv(isPresented: $isChartPresented) {
                                            VStack {

                                                ChartView()
                                                        .padding(.top, 15)

                                                Button(
                                                        action: { isChartPresented.toggle() },
                                                        label: { Text("close").fontWeight(.light) }
                                                )
                                                        .padding(.bottom, 4)
                                            }
                                        }

                                ChartHistoryButton(text: "History", iconName: "list.bullet.rectangle", iconSize: 17) {
                                    isHistoryPresented = true
                                }
                                        .sheetEnv(isPresented: $isHistoryPresented) {
                                            ZStack {
                                                c.bg.edgesIgnoringSafeArea(.all)
                                                HistoryView(isHistoryPresented: $isHistoryPresented)
                                            }
                                                    // todo
                                                    .interactiveDismissDisabled()
                                        }

                                Spacer()

                                Button(
                                        action: { isEditActivitiesPresented = true },
                                        label: {
                                            Text("Edit")
                                                    .font(.system(size: secondaryFontSize, weight: secondaryFontWeight))
                                                    .padding(.trailing, timerHintHPadding)
                                        }
                                )
                                        .padding(.trailing, listEngPadding)
                                        .sheetEnv(
                                                isPresented: $isEditActivitiesPresented
                                        ) {
                                            EditActivitiesSheet(
                                                    isPresented: $isEditActivitiesPresented
                                            )
                                        }
                            }
                                    .frame(height: listItemHeight)

                            Padding(vertical: bottomContentPadding)
                        }
                    }
                }
            }
        }
                .frame(maxHeight: sheetHeight)
                .background(bgColor)
                .listStyle(.plain)
                .listSectionSeparatorTint(.clear)
                .onDisappear {
                    sheetActivity = nil
                }
    }
}

private struct MyButtonStyle: ButtonStyle {

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration
                .label
                .frame(height: listItemHeight)
                .background(configuration.isPressed ? c.dividerFg : bgColor)
    }
}

private struct ActivityTimerSheet: View {

    @State private var vm: ActivityTimerSheetVM

    @Binding private var isPresented: Bool
    private let onStart: () -> ()

    @State private var formTimeItemsIdx: Int32 = 0.toInt32()

    static let RECOMMENDED_HEIGHT = 400.0 // Approximately

    init(
            activity: ActivityModel,
            isPresented: Binding<Bool>,
            timerContext: ActivityTimerSheetVM.TimerContext?,
            onStart: @escaping () -> ()
    ) {
        self._isPresented = isPresented
        self.onStart = onStart
        _vm = State(initialValue: ActivityTimerSheetVM(activity: activity, timerContext: timerContext))
    }

    var body: some View {

        VMView(vm: vm, stack: .VStack()) { state in

            HStack(spacing: 4) {

                Button(
                        action: { isPresented.toggle() },
                        label: { Text("Cancel") }
                )

                Spacer()

                Text(state.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)

                Spacer()

                Button(
                        action: {
                            vm.start {
                                onStart()
                            }
                        },
                        label: {
                            Text("Start")
                                    .fontWeight(.bold)
                        }
                )
            }
                    .padding(.horizontal, 25)
                    .padding(.top, 24)

            // Plus padding from picker
            if let note = state.note {
                Text(note)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 6)
            }

            Spacer()


            Picker(
                    "Time",
                    selection: $formTimeItemsIdx
            ) {
                ForEach(state.timeItems, id: \.idx) { item in
                    Text(item.title)
                }
            }
                    .onChange(of: formTimeItemsIdx) { newValue in
                        vm.setFormTimeItemIdx(newIdx: newValue)
                    }
                    .onAppear {
                        formTimeItemsIdx = state.formTimeItemIdx
                    }
                    .pickerStyle(.wheel)
                    .foregroundColor(.primary)
                    .padding(.bottom, state.note != nil ? 30 : 5)

            Spacer()
        }
    }
}

private struct ChartHistoryButton: View {

    let text: String
    let iconName: String
    let iconSize: CGFloat
    let onClick: () -> Void

    var body: some View {
        Button(
                action: { onClick() },
                label: {
                    HStack {
                        Image(systemName: iconName)
                                .font(.system(size: iconSize, weight: .thin))
                                .padding(.trailing, 3 + onePx)
                        Text(text)
                                .font(.system(size: secondaryFontSize, weight: secondaryFontWeight))
                    }
                }
        )
    }
}
