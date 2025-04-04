create or replace package "VALIDATION_PKG" as

procedure p_validate_training_columns;

procedure p_validate_exercises_columns;

procedure p_validate_series_columns;

procedure p_validate_training_data;

procedure p_validate_exercises_data;

procedure p_validate_series_data;

end "VALIDATION_PKG";
/