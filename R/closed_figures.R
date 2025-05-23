#' Consort Diagram: publication
#'
#' @description 
#' The closed version of consort_diagram_wb_publication, breaking down study cancellations by treatment_arm.
#' 
#' This consort diagram was made for the Weight Bearing study, and so is unlikely to work for yours.
#' 
#' @param analytic analytic data set that must include 
#' study_id, screened, ineligible, ineligibility_reasons, refused, constraint_other, constraint_other_txt, consented, 
#' discontinued_pre_randomization, injury_type, randomized, 
#' late_ineligible, per_protocol_sample, enrolled, consent_date, death_date, withdraw_date,
#' preinjury_work_status, treatment_arm
#'
#' @return An HTML string containing an image tag with the base64-encoded consort diagram in PNG format.
#' @export
#'
#' @examples
#' 
closed_consort_diagram_wb_publication <- function(analytic){
  
  confirm_stability_of_related_visual('consort_diagram_wb_publication', '9c41ab8e7b3d9d9729ca5e39306c08e0')
  
  analytic <- if_needed_generate_example_data(
    analytic,
    example_constructs = c("screened", "ineligible", "ineligibility_reasons", "refused", "constraint_unavailable",
                           "constraint_other", "constraint_other_txt", "consented", "discontinued_pre_randomization", 
                           "injury_type", "randomized", "late_ineligible", "per_protocol_sample", "enrolled", 
                           "consent_date", "death_date", "withdraw_date", "preinjury_work_status", "followup_expected_12mo", 
                           "completed", "treatment_arm"),
    example_types = c("Boolean", "Boolean", "Category-NS", "Boolean", "Boolean", "Boolean", "Character",
                      "Boolean", "Boolean", "NamedCategory['ankle' 'plateau']", "Boolean", "Boolean", 
                      "Boolean", "Boolean", "Date", "Date", "Date", "Boolean", "Boolean", "Boolean", "TreatmentArm"))
  
  df <- analytic %>% 
    select(study_id, screened, ineligible, ineligibility_reasons, refused, constraint_other, constraint_other_txt, consented, 
           discontinued_pre_randomization, injury_type, randomized, constraint_unavailable,
           late_ineligible, per_protocol_sample, enrolled, consent_date, death_date, withdraw_date,
           preinjury_work_status, followup_expected_12mo, completed, treatment_arm)
  
  ir_count <- df %>%
    select(study_id, ineligibility_reasons) %>%
    separate_rows(ineligibility_reasons, sep = '; ') %>%
    count(ineligibility_reasons) %>%
    arrange(desc(n)) %>%
    filter(!is.na(ineligibility_reasons)) %>%
    mutate(ineligibility_reasons = if_else(row_number() >= 7, "Other reason", ineligibility_reasons)) %>%
    group_by(ineligibility_reasons) %>%
    summarise(n = sum(n), .groups = "drop") %>%
    arrange(if_else(ineligibility_reasons == "Other reason", Inf, -n))
  
  screened <- sum(analytic$screened, na.rm = TRUE)
  ineligible <- sum(analytic$ineligible, na.rm = TRUE)
  
  multi_reason <- sum(str_detect(analytic$ineligibility_reasons, ';'), na.rm = TRUE)
  
  refused <- sum(analytic$refused, na.rm = TRUE)
  constraint <- sum(analytic$constraint_other, na.rm = TRUE)
  constraint_unavailable <- sum(analytic$constraint_unavailable, na.rm = TRUE)
  
  late_discontinuation <- sum(df$discontinued_pre_randomization & 
                                df$consented, na.rm = TRUE)
  
  plateau_injuries <- sum(df$injury_type=='plateau', na.rm = TRUE)
  randomized <- sum(df$injury_type=='ankle', na.rm = TRUE)
  
  randomized_a <- sum(df$treatment_arm == 'Group A' & df$injury_type=='ankle', na.rm = TRUE)
  randomized_b <- sum(df$treatment_arm == 'Group B' & df$injury_type=='ankle', na.rm = TRUE)
  
  df_a <- df %>% filter(treatment_arm == 'Group A')
  df_b <- df %>% filter(treatment_arm == 'Group B')
  
  late_ineligible_a <- sum(df_a$late_ineligible, na.rm = TRUE)
  late_ineligible_b <- sum(df_b$late_ineligible, na.rm = TRUE)
  
  diverging_review_a <- sum(!df_a$per_protocol_sample, na.rm = TRUE)
  diverging_review_b <- sum(!df_b$per_protocol_sample, na.rm = TRUE)
  
  died_a <- sum(as.Date(df_a$death_date)-as.Date(df_a$consent_date)<365, na.rm = TRUE)
  died_b <- sum(as.Date(df_b$death_date)-as.Date(df_b$consent_date)<365, na.rm = TRUE)
  
  withdrew_a <- sum(as.Date(df_a$withdraw_date)-as.Date(df_a$consent_date)<365, na.rm = TRUE)
  withdrew_b <- sum(as.Date(df_b$withdraw_date)-as.Date(df_b$consent_date)<365, na.rm = TRUE)
  
  today <- Sys.Date()
  
  percent_expected_a <- format_count_percent(sum(df_a$completed, na.rm = TRUE),
                                           sum(df_a$followup_expected_12mo, na.rm = TRUE), decimals = 2)
  working_df_a <- df_a %>% filter(preinjury_work_status&injury_type=='ankle')
  working_percent_expected_a <- format_count_percent(sum(today-as.Date(working_df_a$consent_date)>365, na.rm = TRUE),
                                                   sum(!is.na(working_df_a$consent_date), na.rm = TRUE), decimals = 2)
  
  percent_expected_b <- format_count_percent(sum(df_b$completed, na.rm = TRUE),
                                             sum(df_b$followup_expected_12mo, na.rm = TRUE), decimals = 2)
  working_df_b <- df_b %>% filter(preinjury_work_status&injury_type=='ankle')
  working_percent_expected_b <- format_count_percent(sum(today-as.Date(working_df_b$consent_date)>365, na.rm = TRUE),
                                                     sum(!is.na(working_df_b$consent_date), na.rm = TRUE), decimals = 2)
  
  
  consort_diagram <- grViz(paste0('
    digraph g {
      graph [layout=fdp, overlap = true, fontsize=1, splines=polyline]
      
      title [style="rounded,filled", fillcolor="#a4d3ee", pos="2,5.5!", shape = box, width=2.4, height=.5, 
        label = "', screened, ' - Patients screened for eligibility"];
        
      box1 [style="rounded,filled", fillcolor="#a4d3ee", pos="2,3.25!", shape = box, width=2.4, height=.5, 
      labeljust=l,
      label = <
        <TABLE BORDER="0" CELLBORDER="0" CELLPADDING="0">
          <TR><TD ALIGN="LEFT">', ineligible, ' - Did not meet eligibility criteria</TD></TR>
          <TR><TD ALIGN="LEFT">- ', ir_count$n[1], ' - ', ir_count$ineligibility_reasons[1], '</TD></TR>
          <TR><TD ALIGN="LEFT">- ', ir_count$n[2], ' - ', ir_count$ineligibility_reasons[2], '</TD></TR>
          <TR><TD ALIGN="LEFT">- ', ir_count$n[3], ' - ', ir_count$ineligibility_reasons[3], '</TD></TR>
          <TR><TD ALIGN="LEFT">- ', ir_count$n[4], ' - ', ir_count$ineligibility_reasons[4], '</TD></TR>
          <TR><TD ALIGN="LEFT">- ', ir_count$n[5], ' - ', ir_count$ineligibility_reasons[5], '</TD></TR>
          <TR><TD ALIGN="LEFT">- ', ir_count$n[6], ' - ', ir_count$ineligibility_reasons[6], '</TD></TR>
          <TR><TD ALIGN="LEFT">- ', multi_reason, ' - Had multiple ineligibility reasons</TD></TR>
          <TR><TD ALIGN="LEFT">', refused, ' - Declined consent</TD></TR>
          <TR><TD ALIGN="LEFT">', constraint_unavailable, ' - Patient not available for consent</TD></TR>
          <TR><TD ALIGN="LEFT">', constraint, ' - Had other reasons not enrolled</TD></TR>
          <TR><TD ALIGN="LEFT">', late_discontinuation, ' - Discontinued after consent, prior to randomization</TD></TR>
          <TR><TD ALIGN="LEFT">', plateau_injuries, ' - Enrolled patients with tibial plateau fractures</TD></TR>
        </TABLE>
      >];
        
      title2 [style="rounded,filled", fillcolor="#a4d3ee", pos="2,1!", shape = box, width=2.4, height=.5, 
        label = "', randomized, ' - Underwent randomization"];
        
      box2 [style="rounded,filled", fillcolor="#a4d3ee", pos="-0.25,-1!", shape = box, width=2.4, height=.5, labeljust=l,
        label = <
          <TABLE BORDER="0" CELLBORDER="0" CELLPADDING="0">
            <TR><TD ALIGN="LEFT">', randomized_a, ' - Assigned to early weight bearing</TD></TR>
            <TR><TD ALIGN="LEFT">- ', late_ineligible_a, ' - Late ineligible</TD></TR>
            <TR><TD ALIGN="LEFT">- ', diverging_review_a, ' - Weight bearing instructions review diverged</TD></TR>
            <TR><TD ALIGN="LEFT">     from protocol</TD></TR>
            <TR><TD ALIGN="LEFT">', randomized_a-late_ineligible_a-diverging_review_a, ' - Included in primary analysis</TD></TR>
            <TR><TD ALIGN="LEFT">- ', died_a, ' - Died prior to 365 days</TD></TR>
            <TR><TD ALIGN="LEFT">- ', withdrew_a, ' - Withdrew prior to 365 days</TD></TR>
            <TR><TD ALIGN="LEFT">', percent_expected_a, ' - 12 Month follow-up complete</TD></TR>
            <TR><TD ALIGN="LEFT">(out of expected)</TD></TR>
            <TR><TD ALIGN="LEFT">', working_percent_expected_a, ' - Pre-injury working patients with</TD></TR>
            <TR><TD ALIGN="LEFT">expected 12 Month Follow-up</TD></TR>
          </TABLE>
        >];
          
      box3 [style="rounded,filled", fillcolor="#a4d3ee", pos="4.25,-1!", shape = box, width=2.4, height=.5, labeljust=l,
        label = <
          <TABLE BORDER="0" CELLBORDER="0" CELLPADDING="0">
            <TR><TD ALIGN="LEFT">', randomized_b, ' - Assigned to delayed weight bearing</TD></TR>
            <TR><TD ALIGN="LEFT">- ', late_ineligible_b, ' - Late ineligible</TD></TR>
            <TR><TD ALIGN="LEFT">- ', diverging_review_b, ' - Weight bearing instructions review diverged</TD></TR>
            <TR><TD ALIGN="LEFT">from protocol</TD></TR>
            <TR><TD ALIGN="LEFT">', randomized_b-late_ineligible_b-diverging_review_b, ' - Included in primary analysis</TD></TR>
            <TR><TD ALIGN="LEFT">- ', died_b, ' - Died prior to 365 days</TD></TR>
            <TR><TD ALIGN="LEFT">- ', withdrew_b, ' - Withdrew prior to 365 days</TD></TR>
            <TR><TD ALIGN="LEFT">', percent_expected_b, ' - 12 Month follow-up complete</TD></TR>
            <TR><TD ALIGN="LEFT">(out of expected)</TD></TR>
            <TR><TD ALIGN="LEFT">', working_percent_expected_b, ' - Pre-injury working patients with</TD></TR>
            <TR><TD ALIGN="LEFT">expected 12 Month Follow-up</TD></TR>
          </TABLE>
        >]
    }
  '))
  svg_content <- DiagrammeRsvg::export_svg(consort_diagram)
  temp_svg_path <- tempfile(fileext = ".svg")
  writeLines(svg_content, temp_svg_path)
  temp_png_path <- tempfile(fileext = ".png")
  rsvg::rsvg_png(temp_svg_path, temp_png_path, width = 1200, height = 1200)
  image_data <- base64enc::base64encode(temp_png_path)
  img_tag <- sprintf('<img src="data:image/png;base64,%s" alt="Consort Diagram" style="max-width: 100%%; width: 1200px;">', image_data)
  file.remove(c(temp_svg_path, temp_png_path))
  return(img_tag)
}