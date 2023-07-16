package me.timeto.shared.data

import me.timeto.shared.ColorNative
import me.timeto.shared.TextFeatures
import me.timeto.shared.db.ActivityModel
import me.timeto.shared.db.IntervalModel
import me.timeto.shared.textFeatures
import me.timeto.shared.vm.ui.TimerDataUI

class TimerTabActivityData(
    activity: ActivityModel,
    lastInterval: IntervalModel,
    isPurple: Boolean,
) {

    val timerData: TimerDataUI? = run {
        if (activity.id != lastInterval.activity_id)
            return@run null
        TimerDataUI(
            interval = lastInterval,
            isPurple = isPurple,
            defColor = ColorNative.blue,
        )
    }

    val text: String
    val textTriggers: List<TextFeatures.Trigger>

    val note: String?
    val noteTriggers: List<TextFeatures.Trigger>

    init {
        val tfActivity = activity.name.textFeatures()
        text = tfActivity.textNoFeatures
        textTriggers = tfActivity.triggers
        val lastIntervalNote = lastInterval.note
        if (timerData != null && lastIntervalNote != null) {
            val tfNote = lastIntervalNote.textFeatures()
            note = tfNote.textNoFeatures
            noteTriggers = tfNote.triggers
        } else {
            note = null
            noteTriggers = listOf()
        }
    }
}
