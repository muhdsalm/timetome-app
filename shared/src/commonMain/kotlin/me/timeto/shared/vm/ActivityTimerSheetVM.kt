package me.timeto.shared.vm

import kotlinx.coroutines.flow.*
import me.timeto.shared.*
import me.timeto.shared.db.ActivityModel
import me.timeto.shared.db.TaskModel

class ActivityTimerSheetVM(
    val activity: ActivityModel,
    private val timerContext: TimerContext?,
) : __VM<ActivityTimerSheetVM.State>() {

    data class State(
        val title: String,
        val note: String?,
        val formTimeItemIdx: Int,
        val timeItems: List<TimerPickerItem>,
        /// Like inner data class
        private val activity: ActivityModel,
    )

    override val state: MutableStateFlow<State>

    init {
        val note = when (timerContext) {
            is TimerContext.Task -> timerContext.task.text
            null -> null
        }

        val defSeconds = TimerPickerItem.calcDefSeconds(activity, note)
        val timeItems = TimerPickerItem.buildList(defSeconds)

        state = MutableStateFlow(
            State(
                title = activity.nameWithEmoji().textFeatures().textUi(),
                note = note,
                formTimeItemIdx = timeItems.indexOfFirst { it.seconds == defSeconds },
                timeItems = timeItems,
                activity = activity,
            )
        )
    }

    fun start(
        onSuccess: () -> Unit,
    ) = scopeVM().launchEx {
        try {
            val deadline = state.value.timeItems[state.value.formTimeItemIdx].seconds

            val when_: Any = when (timerContext) {
                is TimerContext.Task -> {
                    timerContext.task.startInterval(deadline, activity)
                }
                null -> {
                    activity.startInterval(deadline)
                }
            }

            onSuccess()
        } catch (e: UIException) {
            showUiAlert(e.uiMessage)
        }
    }

    fun setFormTimeItemIdx(newIdx: Int) {
        state.update { it.copy(formTimeItemIdx = newIdx) }
    }

    ///

    sealed class TimerContext {
        class Task(val task: TaskModel) : TimerContext()
    }
}