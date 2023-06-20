package me.timeto.app.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material.ExperimentalMaterialApi
import androidx.compose.material.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import me.timeto.app.*
import me.timeto.shared.vm.RepeatingsListVM

@OptIn(ExperimentalMaterialApi::class)
@Composable
fun RepeatingsListView() {

    val (_, state) = rememberVM { RepeatingsListVM() }

    LazyColumn(
        reverseLayout = true,
        contentPadding = PaddingValues(
            start = TAB_TASKS_PADDING_HALF_H,
            end = TAB_TASKS_PADDING_END,
            bottom = taskListSectionPadding,
            top = taskListSectionPadding
        ),
        modifier = Modifier.fillMaxHeight()
    ) {

        item {

            Text(
                "New Repeating Task",
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = TAB_TASKS_PADDING_HALF_H - 3.dp)
                    .padding(top = taskListSectionPadding)
                    .clip(squircleShape)
                    .background(c.blue)
                    .clickable {
                        Sheet.show { layer ->
                            RepeatingFormSheet(
                                layer = layer,
                                editedRepeating = null
                            )
                        }
                    }
                    .padding(
                        vertical = 10.dp
                    ),
                color = c.white,
                fontWeight = FontWeight.W500,
                fontSize = 16.sp,
                textAlign = TextAlign.Center,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
        }

        itemsIndexed(
            state.repeatingsUI,
            key = { _, i -> i.repeating.id }
        ) { index, repeatingUI ->

            SwipeToAction(
                isStartOrEnd = remember { mutableStateOf(null) },
                modifier = Modifier.clip(squircleShape),
                startView = { SwipeToAction__StartView("Edit", c.blue) },
                endView = { state ->
                    SwipeToAction__DeleteView(
                        state = state,
                        note = repeatingUI.listText,
                        deletionConfirmationNote = repeatingUI.deletionNote,
                    ) {
                        vibrateLong()
                        repeatingUI.delete()
                    }
                },
                onStart = {
                    Sheet.show { layer ->
                        RepeatingFormSheet(
                            layer = layer,
                            editedRepeating = repeatingUI.repeating,
                        )
                    }
                    false
                },
                onEnd = {
                    true
                },
                toVibrateStartEnd = listOf(true, false),
            ) {

                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(c.bg),
                    contentAlignment = Alignment.BottomCenter
                ) {

                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 10.dp)
                    ) {

                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = TAB_TASKS_PADDING_HALF_H),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {

                            Text(
                                repeatingUI.dayLeftString,
                                modifier = Modifier.weight(1f),
                                fontSize = 13.sp,
                                fontWeight = FontWeight.W300,
                                color = c.textSecondary,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis,
                            )

                            Text(
                                repeatingUI.dayRightString,
                                fontSize = 13.sp,
                                fontWeight = FontWeight.W300,
                                color = c.textSecondary,
                                maxLines = 1,
                            )
                        }

                        Text(
                            repeatingUI.listText,
                            modifier = Modifier
                                .padding(horizontal = TAB_TASKS_PADDING_HALF_H)
                                .padding(top = 2.dp),
                            color = c.text,
                        )

                        val badgesHPadding = TAB_TASKS_PADDING_HALF_H - 2.dp
                        val badgesTopPadding = 6.dp

                        TextFeaturesTriggersView(
                            triggers = repeatingUI.textFeatures.triggers,
                            modifier = Modifier.padding(top = badgesTopPadding),
                            contentPadding = PaddingValues(horizontal = badgesHPadding)
                        )
                    }

                    // Remember that the list is reversed
                    if (index > 0)
                        DividerBg(Modifier.padding(start = TAB_TASKS_PADDING_HALF_H))
                }
            }
        }
    }
}
