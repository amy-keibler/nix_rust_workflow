use plotters::{prelude::*, data::fitting_range};

const DATA: [i32; 12] = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144];

fn main() -> eyre::Result<()> {
    let root = BitMapBackend::new("box-plots-for-education.png", (512, 1024)).into_drawing_area();
    root.fill(&WHITE)?;

    let quartiles = Quartiles::new(&DATA);
    println!("Quartiles: {quartiles:?}");
    let values_range = fitting_range(quartiles.values().iter());
    println!("Values Range: {values_range:?}");

    let mut chart = ChartBuilder::on(&root)
        .x_label_area_size(40)
        .y_label_area_size(40)
        .caption("Plotting the Fibonacci Sequence", ("sans-serif", 20))
        .build_cartesian_2d(
            ["Fib"].into_segmented(),
            values_range.start - 10.0..values_range.end + 10.0,
        )?;

    chart.configure_mesh().light_line_style(&WHITE).draw()?;
    chart.draw_series(vec![
        Boxplot::new_vertical(SegmentValue::CenterOf(&"Fib"), &quartiles),
    ])?;
    Ok(())
}
