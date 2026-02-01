"""
NACI 2026: Data Selection Automation Script for EPO TIP
This script executes the SQL data selection and enrichment pipeline in the correct sequence.
Run this script within your TIP Jupyter environment.
"""

import asearch as asr
import os
import time

# Configuration: List of scripts in order of dependency
SQL_SCRIPTS = [
    "01A_Mitigation_selection.sql",
    "01A_Adaptation_selection.sql",
    "01B_Benchmark_construction.sql",
    "02A_Mitigation_enrichment.sql",
    "02A_Adaptation_enrichment.sql",
    "02B_Technical_Aggregations.sql"
]

def run_sql_file(filename, connection):
    print(f"[{time.strftime('%H:%M:%S')}] Executing: {filename}...")
    
    if not os.path.exists(filename):
        print(f"Error: File {filename} not found.")
        return False
        
    with open(filename, 'r') as f:
        sql_content = f.read()
        
    try:
        # Split by semicolon to handle multiple statements if necessary
        # Note: asearch connection.execute often handles batches, but we iterate for safety
        statements = [s.strip() for s in sql_content.split(';') if s.strip()]
        
        for i, stmt in enumerate(statements):
            connection.execute(stmt)
            
        print(f"Successfully finished {filename}")
        return True
    except Exception as e:
        print(f"FAILED executing {filename}: {str(e)}")
        return False

def main():
    print("="*60)
    print("NACI 2026: STARTING DATA SELECTION PIPELINE")
    print("="*60)
    
    # Initialize TIP connection
    try:
        conn = asr.get_connection()
    except Exception as e:
        print(f"CRITICAL: Could not establish asearch connection. {str(e)}")
        return

    success_count = 0
    for script in SQL_SCRIPTS:
        if run_sql_file(script, conn):
            success_count += 1
        else:
            print("Stopping pipeline due to error.")
            break
            
    print("="*60)
    if success_count == len(SQL_SCRIPTS):
        print("PIPELINE COMPLETED SUCCESSFULLY")
    else:
        print(f"PIPELINE STOPPED: {success_count}/{len(SQL_SCRIPTS)} scripts succeeded.")
    print("="*60)

if __name__ == "__main__":
    main()
