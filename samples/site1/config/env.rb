PROJECT_ROOT = File.expand_path('../..', __FILE__)
DOCUMENT_ROOT = File.expand_path('../../public', __FILE__)
Alfa::TFile.project_root = PROJECT_ROOT
Alfa::TFile.document_root = DOCUMENT_ROOT

require File.expand_path('../db', __FILE__)