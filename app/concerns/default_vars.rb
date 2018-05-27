module  DefaultVars
  
  JSA_DIVISIONS = ['Health Care', 'Interim Staffing']
  
  JSA_INDUSTRIES = ['advertising',
                    'aerospace',
                    'apparel',
                    'admin - clerical',
                    'automotive',
                    'banking',
                    'biotech',
                    'business development',
                    'business opportunity',
                    'construction',
                    'contracting supplies',
                    'consultant',
                    'cosmetics',
                    'customer service',
                    'design',
                    'distribution - shipping',
                    'education',
                    'electronicparts',
                    'engineering',
                    'entry level',
                    'executive',
                    'facilities',
                    'food manufacturing and distribution',
                    'finance',
                    'franchise',
                    'furniture manufacturing',
                    'general business',
                    'general labor',
                    'government',
                    'government - federal',
                    'health care',
                    'hospitality - hotel',
                    'human resources',
                    'industrial machining',
                    'information technology',
                    'installation - maint - repair',
                    'insurance',
                    'inventory',
                    'lighting manufacturing',
                    'legal',
                    'legal admin',
                    'logistics',
                    'machine shop',
                    'management',
                    'manufacturing',
                    'manufacturing and distribution',
                    'marketing',
                    'media - journalism - newspaper',
                    'medical manufacturing',
                    'metal manufacturing',
                    'nonprofit - social services',
                    'nurse',
                    'other',
                    'paper manufacturing',
                    'pharmaceutical',
                    'plastic manufacturing',
                    'plumbing supplies',
                    'professional services',
                    'purchasing - procurement',
                    'qa - quality control',
                    'real estate',
                    'research',
                    'restaurant - food service',
                    'retail',
                    'sales',
                    'science',
                    'skilled labor - trades',
                    'strategy - planning',
                    'supply chain',
                    'telecommunications',
                    'transportation and shipping',
                    'veterinary services',
                    'warehouse' ]
                    
  JOB_SOURCES = ['Aging Services',
                 'AAHSA',
                 'AHCA',
                 'Arizona Healthcare Association',
                 'COHCA',                 
                 'CAHF',
                 'CAHSAH',
                 'CALA',
                 'Careerbuilder',
                 'employee import',
                 'FHCA',
                 'LinkedIn',
                 'manta',
                 'medicare.gov',
                 'NADONA',
                 'JSA Website',
                 'Indeed',
                 'newspaper',
                 'recruiter',
                 'referral',
                 'radio',
                 'state affiliate website',
                 'trade show'] + DefaultVars::JSA_INDUSTRIES
  
  JOB_MIX_TYPES = [ 'Medicare', 'PVT', 'Medicaid', 'Medical', 'VA', 'HMO' ]
  
  JOB_SPECIAL_UNITS = ['Alzheimers Unit',
                       'Assisted Living',
                       'CCRC',
                       'Hospice',
                       'Hospital',
                       'Home Health Care',
                       'Independent Living',
                       'Psych',
                       'Rehab',
                       'Skilled Nursing',
                       'SubAcute Unit',
                       'Vent and Trach']
  
  JOB_BENEFIT_TYPES = [ 'Health', 'Dental', 'Vision',	'Life',	'Disability',	'Stock Options', 'Tuition', '401K' ]
  
  JOB_BONUS_TYPES = [ 'Fixed', 'Quarterly', 'Annually',	'Percentage' ]
  
  JOB_TITLES = [
    'Administrator',
    'Activities Director',
    'Admissions Coordinator',
    'Assisted Living Coordinator',
    'Certified Nurses Assistant CNA',
    'Charge Nurse',
    'Certified Occupational Therapist Assistant COTA',
    'Certified Speech and Language Pathologist SLP-CC',
    'Chief Executive Officer CEO',
    'Chief Financial Officer CFO',
    'Chief Operating Officer COO',
    'Executive Director',
    'Director of Human Resources',
    'Director of Nursing',
    'Director of Rehabilitation',
    'Director of Sales',
    'Director of Staff Development DSD',
    'Health Services Director',
    'Human Resources',
    'Floor Nurse',
    'Financial Analyst',
    'Interim Director of Nursing',
    'Interim Administrator',
    'MDS Coordinator',
    'Occupational Therapist OTR',
    'Physical Therapist PT',
    'Physical Therapy Assistant PTA',
    'Regional Director of Clinical Operations',
    'Regional Director of Operations',
    'Residential Services Director',
    'Reminiscence Coordinator',
    'Senior Vice President of Operations',
    'Speech Language Pathologist SLP',
    'Traveling Administrator',
    'Traveling Director of Nursing',
    'VP of Clinical Operations',
    'VP of Operations' ]
                
  JOB_HIRE_TYPES = [ 'Consulting',
                'Contract',
                'Contract to Hire',
                'Direct Hire',
                'Full-Time',
                'Perm',
                'Temp to Perm' ]
  
  JOB_WAGE_TYPES = ['Salary', 'Hourly', 'Unknown']
  
  JOB_LICENSES = ['COTA', 'LCSW', 'LPN/LVN', 'LSW', 'MDS/RNAC/AANAC', 'NHA', 'OT', 'PT', 'PTA', 'RCFE/ALF', 'RN', 'PA-C']

  CLIENT_STATE_TYPES = [ { :term => "veteran_client",  :value => 0},
                         { :term => "new_client",      :value => 1},
                         { :term => "marketing",       :value => 2},
                         { :term => "needs_marketing", :value => 3},
                         { :term => "not_interested",  :value => 4},
                         { :term => "flagged",         :value => 5} ]            
  
  STATE_TYPES = [ { :term => "placed",         :value => 0},
                  { :term => "interviewing",   :value => 1},
                  { :term => "pending",        :value => 2},
                  { :term => "searching",      :value => 3},
                  { :term => "on_hold",        :value => 4},
                  { :term => "flagged",        :value => 5} ]
                  
  JOB_STATE_TYPES = [ { :term => "placed",            :value => 0},
                      { :term => "interviewing",      :value => 1},
                      { :term => "pending",           :value => 2},
                      { :term => "searching",         :value => 3},
                      { :term => "on_hold",           :value => 4},
                      { :term => "filled_internally", :value => 6},                      
                      { :term => "Closed",            :value => 7},
                      { :term => "flagged",           :value => 5} ]                              
                      
  APPLICANT_TYPES = [ { :term => "first_contact",       :value => 0},
                      { :term => "resume",              :value => 1},
                      { :term => "internal_interview",  :value => 2},
                      { :term => "resume_submited",     :value => 3},
                      { :term => "phone_interview",     :value => 4},
                      { :term => "personal_interview",  :value => 5},
                      { :term => "checking_references", :value => 6},
                      { :term => "final_interview",     :value => 7},
                      { :term => "placed",              :value => 8},
                      { :term => "pending_offer",       :value => 12},
                      { :term => "on_hold",             :value => 9},
                      { :term => "not_match",           :value => 10},
                      { :term => "flagged",             :value => 11} ] 
                    
  ALLOWED_ACTIVITY_STATES = %w( placed
                                interviewing
                                pending
                                searching
                                holding
                                flagged
                                first_contact
                                resume_submited
                                phone_interview
                                personal_interview
                                checking_references
                                on_hold
                                not_match
                                veteran_client
                                new_client
                                needs_marketing
                                marketing
                                pending_offer
                                closed
                                filled_internally )
                    
  ALLOWED_ATTACHMENT_PARENT_TYPES = %w( User Candidate Client Job Employee DocTemplate )                                          
                    
  EDUCATION_TYPES = ['Assoc', 'Bachelors', 'Master', 'PhD', 'BSN' ]
  
  INTERVIEW_TYPES = ['Phone', 'In-Person']
  
  EXCLUDED_LOGINS = ['admin', 'Admin', 'ADMIN', 'JSA', 'jsa', 'jsaSearchInc']
  
  ALLOWED_NOTE_PARENT_TYPES = %w{ User Employee Client Candidate Job Contact }
  
  All_US_STATES = [["Alaska", "AK"], ["Alabama", "AL"], ["Arkansas", "AR"], ["Arizona", "AZ"], 
  ["California", "CA"], ["Colorado", "CO"], ["Connecticut", "CT"], ["District of Columbia", "DC"], 
  ["Delaware", "DE"], ["Florida", "FL"], ["Georgia", "GA"], ["Hawaii", "HI"], ["Iowa", "IA"], 
  ["Idaho", "ID"], ["Illinois", "IL"], ["Indiana", "IN"], ["Kansas", "KS"], ["Kentucky", "KY"], 
  ["Louisiana", "LA"], ["Massachusetts", "MA"], ["Maryland", "MD"], ["Maine", "ME"], ["Michigan", "MI"], 
  ["Minnesota", "MN"], ["Missouri", "MO"], ["Mississippi", "MS"], ["Montana", "MT"], ["North Carolina", "NC"], 
  ["North Dakota", "ND"], ["Nebraska", "NE"], ["New Hampshire", "NH"], ["New Jersey", "NJ"], 
  ["New Mexico", "NM"], ["Nevada", "NV"], ["New York", "NY"], ["Ohio", "OH"], ["Oklahoma", "OK"], 
  ["Oregon", "OR"], ["Pennsylvania", "PA"], ["Rhode Island", "RI"], ["South Carolina", "SC"], ["South Dakota", "SD"], 
  ["Tennessee", "TN"], ["Texas", "TX"], ["Utah", "UT"], ["Virginia", "VA"], ["Vermont", "VT"], 
  ["Washington", "WA"], ["Wisconsin", "WI"], ["West Virginia", "WV"], ["Wyoming", "WY"]]
  
end