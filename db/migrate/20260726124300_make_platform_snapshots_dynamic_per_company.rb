class MakePlatformSnapshotsDynamicPerCompany < ActiveRecord::Migration[8.1]
  def change
    # null company_id = the organization's own results for that platform+scan;
    # a present company_id = a tracked competitor's results for that
    # platform+scan. Replaces competitor_snapshots' fixed chatgpt/claude/
    # google_ai columns so the competitor table can show one column per
    # actually-integrated AI platform instead of three hardcoded ones.
    remove_index :platform_snapshots, [ :scan_id, :ai_platform_id ], unique: true
    add_reference :platform_snapshots, :company, foreign_key: true, null: true
    add_index :platform_snapshots, [ :scan_id, :ai_platform_id, :company_id ], unique: true, name: "index_platform_snapshots_on_scan_platform_company"

    remove_column :competitor_snapshots, :chatgpt_mentions, :integer, default: 0, null: false
    remove_column :competitor_snapshots, :claude_mentions, :integer, default: 0, null: false
    remove_column :competitor_snapshots, :google_ai_mentions, :integer, default: 0, null: false
  end
end
