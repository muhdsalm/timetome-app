package me.timeto.app.ui

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.padding
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import me.timeto.app.*
import me.timeto.app.R
import me.timeto.shared.ColorRgba
import me.timeto.shared.vm.ReadmeSheetVM

private val hPadding = MyListView.PADDING_OUTER_HORIZONTAL

private val imagesHBetween = 4.dp
private val imagesHBlock = 10.dp
private val imagesShape = SquircleShape(len = 50f)

@Composable
fun ReadmeSheet(
    layer: WrapperView.Layer,
) {

    val (_, state) = rememberVM { ReadmeSheetVM() }

    VStack(
        modifier = Modifier
            .background(c.sheetBg)
    ) {

        val scrollState = rememberScrollState()

        Sheet__HeaderView(
            title = state.title,
            scrollState = scrollState,
            bgColor = c.sheetBg,
        )

        VStack(
            modifier = Modifier
                .verticalScroll(state = scrollState)
                .padding(bottom = 20.dp)
                .weight(1f),
        ) {

            state.paragraphs.forEach { paragraph ->

                when (paragraph) {

                    is ReadmeSheetVM.Paragraph.Text -> PTextView(paragraph.text)

                    is ReadmeSheetVM.Paragraph.ChartImages -> {

                        HStack(
                            modifier = Modifier
                                .padding(top = 20.dp)
                                .padding(horizontal = imagesHBlock),
                        ) {
                            ChartImageView()
                            ChartImageView()
                            ChartImageView()
                        }
                    }
                }
            }
        }

        Sheet__BottomViewClose {
            layer.close()
        }
    }
}

@Composable
private fun PTextView(
    text: String,
    topPadding: Dp = 16.dp,
    fontWeight: FontWeight = FontWeight.Normal,
) {
    Text(
        text = text,
        modifier = Modifier
            .padding(horizontal = hPadding)
            .padding(top = topPadding),
        color = c.white,
        lineHeight = 22.sp,
        fontWeight = fontWeight,
    )
}

private val imageBorderColor = ColorRgba(96, 96, 96).toColor()

@Composable
private fun RowScope.ChartImageView() {
    Image(
        painter = painterResource(R.drawable.readme_chart_1),
        modifier = Modifier
            .padding(horizontal = imagesHBetween)
            .clip(imagesShape)
            .border(1.dp, imageBorderColor, shape = imagesShape)
            .weight(1f),
        contentDescription = "todo image",
        contentScale = ContentScale.Fit,
    )
}
