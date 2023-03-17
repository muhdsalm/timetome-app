import SwiftUI
import shared

struct TextFeaturesTimerFormView: View {

    private let formUI: TextFeaturesFormUI
    private let onChange: (TextFeatures) -> Void

    @State private var isActivitySheetPresented = false
    @State private var isTimerSheetPresented = false

    init(
            textFeatures: TextFeatures,
            onChange: @escaping (TextFeatures) -> Void
    ) {
        self.onChange = onChange
        formUI = TextFeaturesFormUI(textFeatures: textFeatures)
    }

    var body: some View {

        VStack(spacing: 0) {

            MyListView__ItemView(
                    isFirst: true,
                    isLast: false
            ) {

                MyListView__ItemView__ButtonView(
                        text: formUI.activityTitle,
                        withArrow: true,
                        rightView: AnyView(
                                MyListView__ItemView__ButtonView__RightText(
                                        text: formUI.activityNote,
                                        paddingEnd: 2,
                                        textColor: formUI.activityColorOrNull?.toColor()
                                )
                        )
                ) {
                    hideKeyboard()
                    isActivitySheetPresented = true
                }
                        .sheetEnv(isPresented: $isActivitySheetPresented) {
                            ActivityPickerSheet(
                                    isPresented: $isActivitySheetPresented
                            ) { activity in
                                onChange(formUI.upActivity(activity: activity))
                            }
                        }
            }

            MyListView__ItemView(
                    isFirst: false,
                    isLast: true,
                    withTopDivider: true
            ) {

                MyListView__ItemView__ButtonView(
                        text: formUI.timerTitle,
                        withArrow: true,
                        rightView: AnyView(
                                MyListView__ItemView__ButtonView__RightText(
                                        text: formUI.timerNote,
                                        paddingEnd: 2,
                                        textColor: formUI.timerColorOrNull?.toColor()
                                )
                        )
                ) {
                    hideKeyboard()
                    isTimerSheetPresented = true
                }
                        .sheetEnv(isPresented: $isTimerSheetPresented) {
                            TimerPickerSheet(
                                    isPresented: $isTimerSheetPresented,
                                    title: "Timer",
                                    doneText: "Done",
                                    defMinutes: 30
                            ) { seconds in
                                onChange(formUI.upTimer(seconds: seconds.toInt32()))
                            }
                                    .presentationDetentsMediumIf16()
                        }
            }
        }
    }
}
