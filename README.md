# Olympic Results Star Schema (MySQL)

## 📊 Project Overview

This project focuses on transforming a large, flat Olympic results dataset into a structured format suitable for analysis. Below is a description of each column found in the original staging table:

| Column Name   | Description                                                                 |
|---------------|-----------------------------------------------------------------------------|
| ID            | Unique identifier for each athlete-event record.                            |
| Name          | Full name of the athlete.                                                    |
| Sex           | Gender of the athlete (`M` for male, `F` for female).                        |
| Age           | Age of the athlete at the time of the event (may contain nulls).            |
| Height        | Height of the athlete in centimeters (may contain nulls).                   |
| Weight        | Weight of the athlete in kilograms (may contain nulls).                     |
| Team          | Name of the country or team the athlete represents.                         |
| NOC           | National Olympic Committee code (three-letter abbreviation, e.g., `USA`).   |
| Games         | Combination of year and season (e.g., `2000 Summer`).                       |
| Year          | Year in which the Olympic Games took place.                                 |
| Season        | Season of the Olympic Games (`Summer` or `Winter`).                         |
| City          | Host city for the Olympic Games.                                            |
| Sport         | General category of the event (e.g., `Athletics`, `Swimming`).              |
| Event         | Specific event competed in (e.g., `100m Freestyle`, `Basketball Men’s Team`).|
| Medal         | Medal won by the athlete (`Gold`, `Silver`, `Bronze`, or null if none).     |
| NOC_Region    | Full region or country name associated with the `NOC` code.                 |
| NOC_notes     | Additional notes or clarifications about the NOC (optional/nullable).       |

This staging table was used as the starting point for normalization into a star schema for analytics purposes.
