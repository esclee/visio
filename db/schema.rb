# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140702101530) do

  create_table "budgets", :force => true do |t|
    t.string   "budget_type"
    t.string   "scenario"
    t.integer  "amount",               :limit => 8, :default => 0
    t.string   "plan_id"
    t.string   "ppg_id"
    t.string   "goal_id"
    t.string   "output_id"
    t.string   "problem_objective_id"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.boolean  "is_deleted",                        :default => false
    t.integer  "year"
    t.datetime "found_at"
    t.string   "operation_id"
    t.string   "pillar"
  end

  add_index "budgets", ["created_at"], :name => "index_budgets_on_created_at"
  add_index "budgets", ["goal_id"], :name => "index_budgets_on_goal_id"
  add_index "budgets", ["is_deleted"], :name => "index_budgets_on_is_deleted"
  add_index "budgets", ["output_id"], :name => "index_budgets_on_output_id"
  add_index "budgets", ["plan_id", "ppg_id", "goal_id", "problem_objective_id", "output_id", "scenario", "year", "budget_type"], :name => "by_uniqueness", :unique => true, :length => {"plan_id"=>60, "ppg_id"=>10, "goal_id"=>2, "problem_objective_id"=>60, "output_id"=>60, "scenario"=>10, "year"=>nil, "budget_type"=>3}
  add_index "budgets", ["plan_id", "ppg_id", "goal_id"], :name => "index_budgets_on_plan_id_and_ppg_id_and_goal_id"
  add_index "budgets", ["problem_objective_id"], :name => "index_budgets_on_problem_objective_id"

  create_table "countries", :force => true do |t|
    t.text     "latlng"
    t.string   "iso3"
    t.string   "iso2"
    t.string   "region"
    t.string   "subregion"
    t.text     "un_names"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "expenditures", :force => true do |t|
    t.string   "budget_type"
    t.string   "scenario"
    t.integer  "amount",               :default => 0
    t.string   "plan_id"
    t.string   "ppg_id"
    t.string   "goal_id"
    t.string   "output_id"
    t.string   "problem_objective_id"
    t.integer  "year"
    t.boolean  "is_deleted",           :default => false
    t.datetime "found_at"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "operation_id"
  end

  add_index "expenditures", ["created_at"], :name => "index_expenditures_on_created_at"
  add_index "expenditures", ["goal_id"], :name => "index_expenditures_on_goal_id"
  add_index "expenditures", ["is_deleted"], :name => "index_expenditures_on_is_deleted"
  add_index "expenditures", ["output_id"], :name => "index_expenditures_on_output_id"
  add_index "expenditures", ["plan_id", "ppg_id", "goal_id", "problem_objective_id", "output_id", "scenario", "year", "budget_type"], :name => "by_uniqueness", :unique => true, :length => {"plan_id"=>60, "ppg_id"=>10, "goal_id"=>2, "problem_objective_id"=>60, "output_id"=>60, "scenario"=>10, "year"=>nil, "budget_type"=>3}
  add_index "expenditures", ["problem_objective_id"], :name => "index_expenditures_on_problem_objective_id"
  add_index "expenditures", ["updated_at"], :name => "index_expenditures_on_updated_at"

  create_table "export_modules", :force => true do |t|
    t.text     "state",                  :limit => 2147483647
    t.string   "title"
    t.text     "description"
    t.boolean  "include_parameter_list",                       :default => false
    t.boolean  "include_explaination",                         :default => false
    t.text     "figure_config",          :limit => 2147483647
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
    t.integer  "user_id"
    t.text     "figure_type"
  end

  create_table "fetch_monitors", :force => true do |t|
    t.datetime "starttime"
    t.text     "plans"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "goals", :id => false, :force => true do |t|
    t.string   "id",                            :null => false
    t.string   "name"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "is_deleted", :default => false
    t.datetime "found_at"
  end

  add_index "goals", ["id"], :name => "index_goals_on_id", :unique => true

  create_table "goals_operations", :id => false, :force => true do |t|
    t.string "goal_id",      :null => false
    t.string "operation_id", :null => false
  end

  create_table "goals_plans", :force => true do |t|
    t.string "goal_id", :null => false
    t.string "plan_id", :null => false
  end

  add_index "goals_plans", ["plan_id", "goal_id"], :name => "index_goals_plans_on_plan_id_and_goal_id", :unique => true

  create_table "goals_ppgs", :id => false, :force => true do |t|
    t.string "goal_id", :null => false
    t.string "ppg_id",  :null => false
  end

  create_table "goals_problem_objectives", :id => false, :force => true do |t|
    t.string "goal_id",              :null => false
    t.string "problem_objective_id", :null => false
  end

  create_table "goals_rights_groups", :id => false, :force => true do |t|
    t.string "goal_id",         :null => false
    t.string "rights_group_id", :null => false
  end

  create_table "goals_strategies", :id => false, :force => true do |t|
    t.integer "strategy_id", :null => false
    t.string  "goal_id",     :null => false
  end

  create_table "goals_strategy_objectives", :id => false, :force => true do |t|
    t.integer "strategy_objective_id", :null => false
    t.string  "goal_id",               :null => false
  end

  create_table "indicator_data", :id => false, :force => true do |t|
    t.string   "id",                                      :null => false
    t.integer  "standard"
    t.boolean  "reversal"
    t.integer  "comp_target"
    t.integer  "yer"
    t.integer  "baseline"
    t.integer  "stored_baseline"
    t.integer  "threshold_green"
    t.integer  "threshold_red"
    t.string   "indicator_id"
    t.string   "output_id"
    t.string   "problem_objective_id"
    t.string   "rights_group_id"
    t.string   "goal_id"
    t.string   "ppg_id"
    t.string   "plan_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "operation_id"
    t.boolean  "is_deleted",           :default => false
    t.integer  "myr"
    t.boolean  "is_performance"
    t.integer  "year"
    t.datetime "found_at"
    t.boolean  "missing_budget",       :default => false
    t.integer  "imp_target"
    t.string   "priority"
    t.boolean  "excluded",             :default => false
    t.string   "indicator_type"
  end

  add_index "indicator_data", ["created_at"], :name => "index_indicator_data_on_created_at"
  add_index "indicator_data", ["goal_id"], :name => "index_indicator_data_on_goal_id"
  add_index "indicator_data", ["id"], :name => "index_indicator_data_on_id", :unique => true
  add_index "indicator_data", ["indicator_id", "plan_id", "ppg_id", "goal_id", "problem_objective_id", "operation_id"], :name => "by_uniqueness", :length => {"indicator_id"=>60, "plan_id"=>60, "ppg_id"=>10, "goal_id"=>2, "problem_objective_id"=>60, "operation_id"=>10}
  add_index "indicator_data", ["indicator_id"], :name => "index_indicator_data_on_indicator_id"
  add_index "indicator_data", ["is_deleted"], :name => "index_indicator_data_on_is_deleted"
  add_index "indicator_data", ["is_performance"], :name => "index_indicator_data_on_is_performance"
  add_index "indicator_data", ["output_id"], :name => "index_indicator_data_on_output_id"
  add_index "indicator_data", ["plan_id"], :name => "index_indicator_data_on_plan_id"
  add_index "indicator_data", ["problem_objective_id"], :name => "index_indicator_data_on_problem_objective_id"

  create_table "indicators", :id => false, :force => true do |t|
    t.string   "id",                                :null => false
    t.string   "name"
    t.boolean  "is_performance"
    t.boolean  "is_gsp"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "is_deleted",     :default => false
    t.datetime "found_at"
  end

  add_index "indicators", ["id"], :name => "index_indicators_on_id", :unique => true

  create_table "indicators_operations", :id => false, :force => true do |t|
    t.string "operation_id", :null => false
    t.string "indicator_id", :null => false
  end

  create_table "indicators_outputs", :id => false, :force => true do |t|
    t.string "output_id",    :null => false
    t.string "indicator_id", :null => false
  end

  create_table "indicators_plans", :force => true do |t|
    t.string "plan_id",      :null => false
    t.string "indicator_id", :null => false
  end

  add_index "indicators_plans", ["plan_id", "indicator_id"], :name => "index_indicators_plans_on_plan_id_and_indicator_id", :unique => true

  create_table "indicators_problem_objectives", :id => false, :force => true do |t|
    t.string "problem_objective_id", :null => false
    t.string "indicator_id",         :null => false
  end

  create_table "indicators_strategies", :id => false, :force => true do |t|
    t.integer "strategy_id",  :null => false
    t.string  "indicator_id", :null => false
  end

  create_table "indicators_strategy_objectives", :id => false, :force => true do |t|
    t.integer "strategy_objective_id", :null => false
    t.string  "indicator_id",          :null => false
  end

  create_table "narratives", :id => false, :force => true do |t|
    t.string   "id",                   :null => false
    t.datetime "found_at"
    t.string   "operation_id"
    t.string   "plan_id"
    t.string   "goal_id"
    t.string   "ppg_id"
    t.string   "problem_objective_id"
    t.string   "output_id"
    t.string   "elt_id"
    t.text     "usertxt"
    t.string   "createusr"
    t.string   "report_type"
    t.string   "plan_el_type"
    t.integer  "year"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "narratives", ["id"], :name => "index_narratives_on_id", :unique => true

  create_table "offices", :id => false, :force => true do |t|
    t.string   "id",               :null => false
    t.string   "name"
    t.string   "parent_office_id"
    t.boolean  "head"
    t.datetime "found_at"
    t.string   "operation_id"
    t.string   "plan_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "status"
  end

  add_index "offices", ["id"], :name => "index_offices_on_id", :unique => true

  create_table "operations", :id => false, :force => true do |t|
    t.string   "id",                            :null => false
    t.string   "name"
    t.text     "years"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "is_deleted", :default => false
    t.datetime "found_at"
    t.integer  "country_id"
  end

  add_index "operations", ["id"], :name => "index_operations_on_id", :unique => true

  create_table "operations_outputs", :id => false, :force => true do |t|
    t.string "operation_id", :null => false
    t.string "output_id",    :null => false
  end

  create_table "operations_ppgs", :id => false, :force => true do |t|
    t.string "operation_id", :null => false
    t.string "ppg_id",       :null => false
  end

  create_table "operations_problem_objectives", :id => false, :force => true do |t|
    t.string "problem_objective_id", :null => false
    t.string "operation_id",         :null => false
  end

  create_table "operations_rights_groups", :id => false, :force => true do |t|
    t.string "operation_id",    :null => false
    t.string "rights_group_id", :null => false
  end

  create_table "operations_strategies", :id => false, :force => true do |t|
    t.integer "strategy_id",  :null => false
    t.string  "operation_id", :null => false
  end

  create_table "operations_strategy_objectives", :id => false, :force => true do |t|
    t.integer "strategy_objective_id", :null => false
    t.string  "operation_id",          :null => false
  end

  create_table "outputs", :id => false, :force => true do |t|
    t.string   "id",                            :null => false
    t.string   "name"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "is_deleted", :default => false
    t.datetime "found_at"
  end

  add_index "outputs", ["id"], :name => "index_outputs_on_id", :unique => true

  create_table "outputs_plans", :force => true do |t|
    t.string "plan_id",   :null => false
    t.string "output_id", :null => false
  end

  add_index "outputs_plans", ["plan_id", "output_id"], :name => "index_outputs_plans_on_plan_id_and_output_id", :unique => true

  create_table "outputs_problem_objectives", :id => false, :force => true do |t|
    t.string "problem_objective_id", :null => false
    t.string "output_id",            :null => false
  end

  create_table "outputs_strategies", :id => false, :force => true do |t|
    t.integer "strategy_id", :null => false
    t.string  "output_id",   :null => false
  end

  create_table "outputs_strategy_objectives", :id => false, :force => true do |t|
    t.integer "strategy_objective_id", :null => false
    t.string  "output_id",             :null => false
  end

  create_table "plans", :id => false, :force => true do |t|
    t.string   "id",                                                 :null => false
    t.string   "operation_name"
    t.string   "name"
    t.integer  "year"
    t.string   "operation_id"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.boolean  "is_deleted",                      :default => false
    t.integer  "country_id"
    t.datetime "found_at"
    t.integer  "custom_ppgs_count",               :default => 0,     :null => false
    t.integer  "custom_indicators_count",         :default => 0,     :null => false
    t.integer  "custom_outputs_count",            :default => 0,     :null => false
    t.integer  "custom_problem_objectives_count", :default => 0,     :null => false
    t.integer  "custom_goals_count",              :default => 0,     :null => false
  end

  add_index "plans", ["id"], :name => "index_plans_on_id", :unique => true

  create_table "plans_ppgs", :force => true do |t|
    t.string "plan_id", :null => false
    t.string "ppg_id",  :null => false
  end

  add_index "plans_ppgs", ["plan_id", "ppg_id"], :name => "index_plans_ppgs_on_plan_id_and_ppg_id", :unique => true

  create_table "plans_problem_objectives", :force => true do |t|
    t.string "problem_objective_id", :null => false
    t.string "plan_id",              :null => false
  end

  add_index "plans_problem_objectives", ["plan_id", "problem_objective_id"], :name => "plans_objectives_index", :unique => true

  create_table "plans_rights_groups", :id => false, :force => true do |t|
    t.string "plan_id",         :null => false
    t.string "rights_group_id", :null => false
  end

  create_table "plans_strategies", :id => false, :force => true do |t|
    t.integer "strategy_id", :null => false
    t.string  "plan_id",     :null => false
  end

  create_table "positions", :id => false, :force => true do |t|
    t.string   "id",                                   :null => false
    t.string   "position_reference"
    t.string   "contract_type"
    t.string   "incumbent"
    t.string   "title"
    t.string   "grade"
    t.boolean  "head"
    t.boolean  "fast_track"
    t.string   "parent_position_id"
    t.string   "operation_id"
    t.string   "plan_id"
    t.datetime "found_at"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "office_id"
    t.boolean  "existing",           :default => true
  end

  add_index "positions", ["id"], :name => "index_positions_on_id", :unique => true

  create_table "ppgs", :id => false, :force => true do |t|
    t.string   "id",                                    :null => false
    t.string   "name"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "is_deleted",         :default => false
    t.string   "population_type"
    t.string   "population_type_id"
    t.string   "operation_name"
    t.datetime "found_at"
  end

  add_index "ppgs", ["id"], :name => "index_ppgs_on_id", :unique => true

  create_table "ppgs_strategies", :id => false, :force => true do |t|
    t.integer "strategy_id", :null => false
    t.string  "ppg_id",      :null => false
  end

  create_table "ppgs_strategy_objectives", :id => false, :force => true do |t|
    t.integer "strategy_objective_id", :null => false
    t.string  "ppg_id",                :null => false
  end

  create_table "problem_objectives", :id => false, :force => true do |t|
    t.string   "id",                                :null => false
    t.string   "problem_name"
    t.string   "objective_name"
    t.boolean  "is_excluded"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "is_deleted",     :default => false
    t.datetime "found_at"
  end

  add_index "problem_objectives", ["id"], :name => "index_problem_objectives_on_id", :unique => true

  create_table "problem_objectives_rights_groups", :id => false, :force => true do |t|
    t.string "problem_objective_id", :null => false
    t.string "rights_group_id",      :null => false
  end

  create_table "problem_objectives_strategies", :id => false, :force => true do |t|
    t.integer "strategy_id",          :null => false
    t.string  "problem_objective_id", :null => false
  end

  create_table "problem_objectives_strategy_objectives", :id => false, :force => true do |t|
    t.integer "strategy_objective_id", :null => false
    t.string  "problem_objective_id",  :null => false
  end

  create_table "rights_groups", :id => false, :force => true do |t|
    t.string   "id",                            :null => false
    t.string   "name"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "is_deleted", :default => false
    t.datetime "found_at"
  end

  add_index "rights_groups", ["id"], :name => "index_rights_groups_on_id", :unique => true

  create_table "rights_groups_strategies", :id => false, :force => true do |t|
    t.integer "strategy_id",     :null => false
    t.string  "rights_group_id", :null => false
  end

  create_table "rights_groups_strategy_objectives", :id => false, :force => true do |t|
    t.integer "strategy_objective_id", :null => false
    t.string  "rights_group_id",       :null => false
  end

  create_table "strategies", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.text     "description"
    t.integer  "user_id"
    t.string   "dashboard_type"
  end

  create_table "strategy_objectives", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "strategy_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "users", :force => true do |t|
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "firstname"
    t.string   "lastname"
    t.boolean  "reset_local_db",         :default => false
    t.string   "login",                  :default => "",    :null => false
    t.boolean  "admin",                  :default => false
  end

  add_index "users", ["login"], :name => "index_users_on_login"

end
