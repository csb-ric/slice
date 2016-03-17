# frozen_string_literal: true

require 'test_helper'

class SheetsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @sheet = sheets(:one)
    @project = projects(:one)
  end

  test 'should get index' do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:sheets)
  end

  test 'should get index with invalid project' do
    get :index, project_id: -1
    assert_nil assigns(:sheets)
    assert_redirected_to root_path
  end

  test 'should get paginated index' do
    get :index, project_id: @project, page: 2
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get paginated index order by site' do
    get :index, project_id: @project, order: 'sheets.site_name'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get paginated index order by site descending' do
    get :index, project_id: @project, order: 'sheets.site_name DESC'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get index by design_name' do
    get :index, project_id: @project, order: 'sheets.design_name'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get index by design_name desc' do
    get :index, project_id: @project, order: 'sheets.design_name DESC'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get index by subject_code' do
    get :index, project_id: @project, order: 'sheets.subject_code'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get index by subject_code desc' do
    get :index, project_id: @project, order: 'sheets.subject_code DESC'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get index by project_name' do
    get :index, project_id: @project, order: 'sheets.project_name'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get index by project_name desc' do
    get :index, project_id: @project, order: 'sheets.project_name DESC'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get index by user_name' do
    get :index, project_id: @project, order: 'sheets.user_name'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get index by user_name desc' do
    get :index, project_id: @project, order: 'sheets.user_name DESC'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get attached file' do
    assert_not_equal 0, sheet_variables(:file_attachment).response_file.size
    get :file, id: sheets(:file_attached), project_id: @project, sheet_variable_id: sheet_variables(:file_attachment), variable_id: variables(:file), position: nil

    assert_not_nil response
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet_variable)
    assert_not_nil assigns(:object)

    assert_kind_of String, response.body
    assert_equal File.binread( File.join(CarrierWave::Uploader::Base.root, assigns(:object).response_file.url) ), response.body
  end

  test 'should get attached file in grid' do
    assert_not_equal 0, grids(:has_grid_row_one_attached_file).response_file.size
    get :file, id: sheets(:has_grid_with_file), project_id: @project, sheet_variable_id: sheet_variables(:has_grid_with_file), variable_id: variables(:file), position: 0

    assert_not_nil response
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet_variable)
    assert_not_nil assigns(:object)

    assert_kind_of String, response.body
    assert_equal File.binread( File.join(CarrierWave::Uploader::Base.root, assigns(:object).response_file.url) ), response.body
  end

  test 'should not get non-existent file in grid' do
    assert_equal 0, grids(:has_grid_row_two_no_attached_file).response_file.size
    get :file, id: sheets(:has_grid_with_file), project_id: @project, sheet_variable_id: sheet_variables(:has_grid_with_file), variable_id: variables(:file), position: 1

    assert_not_nil response
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet_variable)
    assert_not_nil assigns(:object)
    assert_equal 0, assigns(:object).response_file.size

    assert_response :success
  end

  test 'should not get attached file for viewer on different site' do
    login(users(:site_one_viewer))
    assert_not_equal 0, sheet_variables(:file_attachment).response_file.size
    get :file, id: sheets(:file_attached), project_id: @project, sheet_variable_id: sheet_variables(:file_attachment), variable_id: variables(:file), position: nil

    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_nil assigns(:variable)
    assert_nil assigns(:sheet_variable)

    assert_redirected_to project_sheets_path(assigns(:project))
  end

  test 'should get new and redirect' do
    get :new, project_id: @project
    assert_redirected_to assigns(:project)
  end

  test 'should create sheet' do
    assert_difference('SheetTransaction.count') do
      assert_difference('Sheet.count') do
        post :create, project_id: @project,
                      subject_id: @sheet.subject,
                      sheet: { design_id: designs(:all_variable_types) },
                      variables: {
                        "#{variables(:dropdown).id}" => 'm',
                        "#{variables(:checkbox).id}" => %w(acct101 econ101),
                        "#{variables(:radio).id}" => '2',
                        "#{variables(:string).id}" => 'This is a string',
                        "#{variables(:text).id}" => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                        "#{variables(:integer).id}" => 30,
                        "#{variables(:numeric).id}" => 180.5,
                        "#{variables(:date).id}" => { month: '05', day: '28', year: '2012' },
                        "#{variables(:file).id}" => { response_file: '' },
                        "#{variables(:time).id}" => { hour: '14', minutes: '30', seconds: '00' },
                        "#{variables(:calculated).id}" => '1234'
                      }
      end
    end

    assert_not_nil assigns(:sheet)
    assert_equal 11, assigns(:sheet).variables.size

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test 'should create sheet with large integer' do
    assert_difference('SheetTransaction.count') do
      assert_difference('Sheet.count') do
        post :create, project_id: @project,
                      subject_id: @sheet.subject,
                      sheet: { design_id: designs(:has_no_validations) },
                      variables: {
                        "#{variables(:integer_no_range).id}" => 127_858_751_212_122_128_384
                      }
      end
    end

    assert_not_nil assigns(:sheet)
    assigns(:sheet).sheet_variables.reload
    assert_equal 127_858_751_212_122_128_384, assigns(:sheet).sheet_variables.first.get_response(:raw)

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test 'should create sheet and save date to correct database format' do
    assert_difference('SheetTransaction.count') do
      assert_difference('Sheet.count') do
        post :create, project_id: @project,
                      subject_id: @sheet.subject,
                      sheet: { design_id: designs(:has_no_validations) },
                      variables: {
                        "#{variables(:date_no_range).id}" => { month: '5', day: '2', year: '1992' }
                      }
      end
    end

    assert_not_nil assigns(:sheet)
    assigns(:sheet).sheet_variables.reload
    assert_equal '1992-05-02', assigns(:sheet).sheet_variables.first.get_response(:raw)

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test 'should create sheet and save time of day to correct database format' do
    assert_difference('SheetTransaction.count') do
      assert_difference('Sheet.count') do
        post :create, project_id: @project,
                      subject_id: @sheet.subject,
                      sheet: { design_id: designs(:has_no_validations) },
                      variables: {
                        "#{variables(:time_of_day_no_range).id}" => { hour: '13', minutes: '2', seconds: '' }
                      }
      end
    end

    assert_not_nil assigns(:sheet)
    assigns(:sheet).sheet_variables.reload
    assert_equal '13:02:00', assigns(:sheet).sheet_variables.first.get_response(:raw)

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  # TODO, rewrite these for subject_events
  # test 'should create sheet with subject schedule and event' do
  #   assert_difference('Sheet.count') do
  #     post :create, project_id: @project, sheet: { design_id: designs(:all_variable_types), subject_schedule_id: subject_schedules(:one).id, event_id: events(:one).id },
  #                   subject_code: subjects(:two).subject_code,
  #                   site_id: subjects(:two).site_id,
  #                   variables: { }
  #   end

  #   assert_not_nil assigns(:sheet)
  #   assert_not_nil assigns(:sheet).event
  #   assert_not_nil assigns(:sheet).subject_schedule

  #   assert_redirected_to project_subject_path(assigns(:sheet).subject.project, assigns(:sheet).subject)
  # end

  # TODO, rewrite these for subject_events
  # test 'should create sheet with and remove subject schedule and event if the subject is changed' do
  #   assert_difference('Sheet.count') do
  #     post :create, project_id: @project, sheet: { design_id: designs(:all_variable_types), subject_schedule_id: subject_schedules(:one).id, event_id: events(:one).id },
  #                   subject_code: subjects(:one).subject_code,
  #                   site_id: subjects(:one).site_id,
  #                   variables: { }
  #   end

  #   assert_not_nil assigns(:sheet)
  #   assert_nil assigns(:sheet).subject_schedule
  #   assert_nil assigns(:sheet).event

  #   assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  # end

  test 'should create sheet with grid' do
    post :create, project_id: @project,
                  subject_id: sheets(:has_grid).subject,
                  sheet: { design_id: designs(:has_grid) },
                  variables: {
                    "#{variables(:grid).id}" => { '13463487147483201' => { "#{variables(:change_options).id}" => '1' },
                                                  '1346351022118849'  => { "#{variables(:change_options).id}" => '2' },
                                                  '1346351034600475'  => { "#{variables(:change_options).id}" => '3' }}
                  }

    assert_not_nil assigns(:sheet)
    assert_equal 1, assigns(:sheet).variables.size
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test 'should not create sheet on invalid project' do
    assert_difference('Sheet.count', 0) do
      post :create, project_id: projects(:four), subject_id: subjects(:one), sheet: { design_id: @sheet.design_id }
    end

    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test 'should not create sheet without design' do
    assert_difference('Sheet.count', 0) do
      post :create, project_id: @project, subject_id: subjects(:one), sheet: { design_id: '' }
    end
    assert_template 'new'
    assert_response :success
  end

  test 'should not create sheet for site viewer' do
    login(users(:site_one_viewer))
    assert_difference('Sheet.count', 0) do
      post :create, project_id: @project, subject_id: subjects(:one), sheet: { design_id: @sheet.design_id }
    end

    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test 'should create sheet for site editor' do
    login(users(:site_one_editor))
    assert_difference('Sheet.count') do
      post :create, project_id: @project, subject_id: subjects(:one), sheet: { design_id: @sheet.design_id }
    end

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test 'should show sheet' do
    get :show, id: @sheet, project_id: @project
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should show sheet to site viewer' do
    login(users(:site_one_viewer))
    get :show, id: @sheet, project_id: @project
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should show sheet with ajax' do
    xhr :get, :show, id: @sheet, project_id: @project, format: 'js'
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_template 'show'
    assert_response :success
  end

  test 'should show sheet with ajax with all variables' do
    xhr :get, :show, id: sheets(:all_variables), project_id: sheets(:all_variables).project_id, format: 'js'
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_template 'show'
    assert_response :success
  end

  test 'should show sheet with grid responses' do
    xhr :get, :show, id: sheets(:has_grid), project_id: @project, format: 'js'
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_template 'show'
    assert_response :success
  end

  test 'should show sheet with attached file' do
    xhr :get, :show, id: sheets(:file_attached), project_id: @project, format: 'js'
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_template 'show'
    assert_response :success
  end

  test 'should show sheet transactions' do
    get :transactions, id: @sheet, project_id: @project
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should not show invalid sheet' do
    get :show, id: -1, project_id: @project
    assert_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_redirected_to project_sheets_path(@project)
  end

  test 'should not show sheet with invalid project' do
    get :show, id: @sheet, project_id: -1
    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test 'should not show transactions for invalid sheet' do
    get :transactions, id: -1, project_id: @project
    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to project_sheets_path(@project)
  end

  test 'should not show transactions for invalid project' do
    get :transactions, id: @sheet, project_id: -1
    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test 'should not show sheet for user from different site' do
    login(users(:site_one_viewer))
    get :show, id: sheets(:three), project_id: @project
    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to project_sheets_path(assigns(:project))
  end

  test 'should print sheet' do
    skip if ENV['TRAVIS'] # Skip this test on Travis since Travis can't generate PDFs
    get :show, project_id: @project, id: @sheet, format: 'pdf'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_response :success
  end

  test 'should print sheet on project that hides values' do
    skip if ENV['TRAVIS'] # Skip this test on Travis since Travis can't generate PDFs
    get :show, project_id: projects(:two), id: sheets(:two), format: 'pdf'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_response :success
  end

  test 'should not print invalid sheet' do
    skip if ENV['TRAVIS'] # Skip this test on Travis since Travis can't generate PDFs
    get :show, project_id: @project, id: -1, format: 'pdf'
    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to project_sheets_path(assigns(:project))
  end

  test 'should show sheet if PDF fails to render' do
    skip if ENV['TRAVIS'] # Skip this test on Travis since Travis can't generate PDFs
    begin
      original_latex = ENV['latex_location']
      ENV['latex_location'] = "echo #{original_latex}"
      get :show, project_id: @project, id: sheets(:three), format: 'pdf'
      assert_not_nil assigns(:project)
      assert_not_nil assigns(:sheet)
      assert_redirected_to [@project, sheets(:three)]
    ensure
      ENV['latex_location'] = original_latex
    end
  end

  test 'should get edit' do
    get :edit, id: @sheet, project_id: @project
    assert_response :success
  end

  test 'should get edit for site editor' do
    login(users(:site_one_editor))
    get :edit, id: @sheet, project_id: @project
    assert_response :success
  end

  test 'should not get edit for site viewer' do
    login(users(:site_one_viewer))
    get :edit, id: @sheet, project_id: @project
    assert_redirected_to root_path
  end

  test 'should not get edit for auto-locked sheet' do
    login(users(:valid))
    get :edit, project_id: projects(:auto_lock), id: sheets(:auto_lock)
    assert_redirected_to [projects(:auto_lock), sheets(:auto_lock)]
  end

  test 'should update sheet' do
    assert_difference('SheetTransaction.count') do
      patch :update, id: @sheet, project_id: @project,
                     sheet: { design_id: designs(:all_variable_types) },
                     variables: {
                       "#{variables(:dropdown).id}" => 'f',
                       "#{variables(:checkbox).id}" => nil,
                       "#{variables(:radio).id}" => '1',
                       "#{variables(:string).id}" => 'This is an updated string',
                       "#{variables(:text).id}" => 'Lorem ipsum dolor sit amet',
                       "#{variables(:integer).id}" => 31,
                       "#{variables(:numeric).id}" => 190.5,
                       "#{variables(:date).id}" => { month: '05', day: '29', year: '2012' },
                       "#{variables(:file).id}" => { response_file: '' }
                     }
    end

    assert_not_nil assigns(:sheet)
    assert_equal 9, assigns(:sheet).variables.size
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test 'should update sheet with grid' do
    patch :update, id: sheets(:has_grid), project_id: sheets(:has_grid).project_id, sheet: { design_id: designs(:has_grid) },
                   variables: {
                    "#{variables(:grid).id}" => { '0' => {  "#{variables(:change_options).id}" => '1',
                                                            "#{variables(:file).id}" => { response_file: { cache: '' } },
                                                            "#{variables(:checkbox).id}" => ['acct101', 'econ101'],
                                                            "#{variables(:height).id}" => '1.5',
                                                            "#{variables(:weight).id}" => '70.0',
                                                            "#{variables(:calculated).id}" => '31.11',
                                                            "#{variables(:integer).id}" => '25',
                                                            "#{variables(:time).id}" => { hour: '11', minutes: '30', seconds: '59' }
                                                          },
                                                  '1' => {  "#{variables(:change_options).id}" => '2',
                                                            "#{variables(:file).id}" => { response_file: { cache: '' } },
                                                            "#{variables(:checkbox).id}" => ['econ101'],
                                                            "#{variables(:height).id}" => '1.5',
                                                            "#{variables(:weight).id}" => '0.0',
                                                            "#{variables(:calculated).id}" => '',
                                                            "#{variables(:integer).id}" => '25',
                                                            "#{variables(:time).id}" => { hour: '13', minutes: '20', seconds: '01' }
                                                          },
                                                  '2' => {  "#{variables(:change_options).id}" => '3',
                                                            "#{variables(:file).id}" => { response_file: { cache: '' } },
                                                            "#{variables(:checkbox).id}" => [],
                                                            "#{variables(:height).id}" => '1.5',
                                                            "#{variables(:weight).id}" => '70.0',
                                                            "#{variables(:calculated).id}" => '31.11',
                                                            "#{variables(:integer).id}" => '25',
                                                            "#{variables(:time).id}" => { hour: '14', minutes: '56', seconds: '33' }
                                                          }
                                                }
                             }

    assert_not_nil assigns(:sheet)
    assert_equal 1, assigns(:sheet).variables.size
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test 'should update sheet with grid and remove top grid row' do
    patch :update, id: sheets(:has_grid), project_id: sheets(:has_grid).project_id, sheet: { design_id: designs(:has_grid) },
                  variables: {
                    "#{variables(:grid).id}" => { '1' => {  "#{variables(:change_options).id}" => '2',
                                                            "#{variables(:file).id}" => { response_file: { cache: '' } },
                                                            "#{variables(:checkbox).id}" => ['econ101'],
                                                            "#{variables(:height).id}" => '1.5',
                                                            "#{variables(:weight).id}" => '0.0',
                                                            "#{variables(:calculated).id}" => '',
                                                            "#{variables(:integer).id}" => '25',
                                                            "#{variables(:time).id}" => { hour: '13', minutes: '20', seconds: '01' }
                                                          },
                                                  '2' => {  "#{variables(:change_options).id}" => '3',
                                                            "#{variables(:file).id}" => { response_file: fixture_file_upload('../../test/support/projects/rails.png') },
                                                            "#{variables(:checkbox).id}" => [],
                                                            "#{variables(:height).id}" => '1.5',
                                                            "#{variables(:weight).id}" => '70.0',
                                                            "#{variables(:calculated).id}" => '31.11',
                                                            "#{variables(:integer).id}" => '25',
                                                            "#{variables(:time).id}" => { hour: '14', minutes: '56', seconds: '33' }
                                                          }
                                                }
                              }

    assert_not_nil assigns(:sheet)
    assert_equal 1, assigns(:sheet).variables.size
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test 'should not update sheet with blank design' do
    patch :update, project_id: @project, id: @sheet, sheet: { design_id: '' }, variables: {}
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_template 'edit'
    assert_response :success
  end

  test 'should not update invalid sheet' do
    patch :update, id: -1, project_id: @project, sheet: { design_id: designs(:all_variable_types) }, variables: {}
    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to project_sheets_path(@project)
  end

  test 'should not update sheet with invalid project' do
    patch :update, id: @sheet, project_id: -1, sheet: { design_id: designs(:all_variable_types) }, variables: {}
    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test 'should not update auto-locked sheet' do
    login(users(:valid))
    assert_difference('SheetVariable.count', 0) do
      patch :update, project_id: projects(:auto_lock), id: sheets(:auto_lock), variables: { variables(:string_on_auto_lock).id.to_s => 'Updated string' }
    end
    assert_equal 'This sheet is locked.', flash[:notice]
    assert_redirected_to [projects(:auto_lock), sheets(:auto_lock)]
  end

  test 'should create sheet unlock request as site editor' do
    login(users(:auto_lock_site_one_editor))
    post :unlock_request, project_id: projects(:auto_lock), id: sheets(:auto_lock)
    assert_redirected_to [projects(:auto_lock), sheets(:auto_lock)]
  end

  test 'should unlock sheet as project editor' do
    login(users(:valid))
    assert_equal true, sheets(:auto_lock).auto_locked?
    post :unlock, project_id: projects(:auto_lock), id: sheets(:auto_lock)
    sheets(:auto_lock).reload
    assert_equal false, sheets(:auto_lock).auto_locked?
    assert_redirected_to [projects(:auto_lock), sheets(:auto_lock)]
  end

  test 'should not unlock sheet as site editor' do
    login(users(:auto_lock_site_one_editor))
    assert_equal true, sheets(:auto_lock).auto_locked?
    post :unlock, project_id: projects(:auto_lock), id: sheets(:auto_lock)
    sheets(:auto_lock).reload
    assert_equal true, sheets(:auto_lock).auto_locked?
    assert_redirected_to root_path
  end

  test 'should remove shareable link as editor' do
    login(users(:admin))
    assert_difference('Sheet.where(authentication_token: nil).count') do
      post :remove_shareable_link, project_id: projects(:three), id: sheets(:external)
    end
    assert_redirected_to [projects(:three), sheets(:external)]
  end

  test 'should get transfer sheet for editor' do
    get :transfer, project_id: @project, id: @sheet

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_response :success
  end

  test 'should not get transfer sheet for viewer' do
    login(users(:site_one_viewer))
    get :transfer, project_id: @project, id: @sheet
    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test 'should transfer sheet to new subject for editor' do
    patch :transfer, project_id: @project, id: @sheet, subject_id: subjects(:two)

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_equal subjects(:two).id, assigns(:sheet).subject_id
    assert_equal nil, assigns(:sheet).subject_event_id
    assert_equal users(:valid).id, assigns(:sheet).last_user_id
    assert_not_nil assigns(:sheet).last_edited_at

    assert_redirected_to [assigns(:project), assigns(:sheet)]
  end

  test 'should undo transfer for subject for editor' do
    patch :transfer, project_id: @project, id: @sheet, subject_id: subjects(:two), undo: '1'

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_equal subjects(:two).id, assigns(:sheet).subject_id
    assert_equal nil, assigns(:sheet).subject_event_id
    assert_equal users(:valid).id, assigns(:sheet).last_user_id
    assert_not_nil assigns(:sheet).last_edited_at

    assert_redirected_to [assigns(:project), assigns(:sheet)]
  end

  test 'should not make changes if transfer does not provide a new subject' do
    patch :transfer, project_id: @project, id: @sheet, subject_id: subjects(:one)

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_redirected_to [assigns(:project), assigns(:sheet)]
  end

  test 'should not transfer sheet to new subject for viewer' do
    login(users(:site_one_viewer))
    patch :transfer, project_id: @project, id: @sheet, subject_id: subjects(:two)

    assert_nil assigns(:project)
    assert_nil assigns(:sheet)

    assert_redirected_to root_path
  end

  test 'should move sheet to subject event for editor' do
    patch :move_to_event, project_id: @project, id: @sheet, subject_event_id: subject_events(:one), format: 'js'

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_equal subject_events(:one).id, assigns(:sheet).subject_event_id
    assert_equal users(:valid).id, assigns(:sheet).last_user_id
    assert_not_nil assigns(:sheet).last_edited_at
    assert_not_nil assigns(:sheet).subject

    assert_template 'move_to_event'
  end

  test 'should not make changes if move_to_event does not provide a new subject' do
    patch :move_to_event, project_id: @project, id: @sheet, format: 'js'

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_response :success
  end

  test 'should not move sheet to subject event for viewer' do
    login(users(:site_one_viewer))
    patch :move_to_event, project_id: @project, id: @sheet, subject_event_id: subject_events(:one), format: 'js'

    assert_nil assigns(:project)
    assert_nil assigns(:sheet)

    assert_response :success
  end

  test 'should destroy sheet' do
    assert_difference('Sheet.current.count', -1) do
      delete :destroy, id: @sheet, project_id: @project
    end

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_redirected_to project_subject_path(@project, @sheet.subject)
  end

  test 'should not destroy sheet with invalid project' do
    assert_difference('Sheet.current.count', 0) do
      delete :destroy, id: @sheet, project_id: -1
    end

    assert_nil assigns(:project)
    assert_nil assigns(:sheet)

    assert_redirected_to root_path
  end

  test 'should not destroy auto-locked sheet' do
    login(users(:valid))
    assert_difference('Sheet.current.count', 0) do
      delete :destroy, project_id: projects(:auto_lock), id: sheets(:auto_lock)
    end
    assert_equal 'This sheet is locked.', flash[:notice]
    assert_redirected_to [projects(:auto_lock), sheets(:auto_lock)]
  end
end
