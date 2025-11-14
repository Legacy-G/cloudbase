import odoo
import odoo.tools.config
import odoo.modules.registry
import odoo.api

# Load Odoo config
odoo.tools.config.parse_config(['--config=odoo.conf'])
odoo.service.server.load_server_wide_modules()
registry = odoo.modules.registry.Registry.new('it2025')

BATCH_SIZE = 500 

with registry.cursor() as cr:
    env = odoo.api.Environment(cr, odoo.SUPERUSER_ID, {'no_check_group': True})

    try:
        # Delete activities linked to dummy students (FK blocker)
        activities = env['op.activity'].search([
            ('student_id.user_id.login', 'like', 'student%'),
            ('student_id.user_id.email', 'like', '%@st.futminna.edu.ng'),
        ])
        print(f"Found {len(activities)} student activities to delete...")
        for i in range(0, len(activities), BATCH_SIZE):
            subset = activities[i:i+BATCH_SIZE]
            subset.sudo().unlink()
            cr.commit()
            print(f"Deleted {i+len(subset)} activities...")

        # Delete student-course links for dummy students
        student_courses = env['op.student.course'].search([
            ('student_id.user_id.login', 'like', 'student%'),
            ('student_id.user_id.email', 'like', '%@st.futminna.edu.ng'),
        ])
        print(f"Found {len(student_courses)} student-course links to delete...")
        for i in range(0, len(student_courses), BATCH_SIZE):
            subset = student_courses[i:i+BATCH_SIZE]
            subset.sudo().unlink()
            cr.commit()
            print(f"Deleted {i+len(subset)} student-course links...")

        # Delete dummy students (ROLL1–ROLL10000) but guarded by email domain
        students = env['op.student'].search([
            ('user_id.login', 'like', 'student%'),
            ('email', 'like', '%@st.futminna.edu.ng'),
        ])
        print(f"Found {len(students)} dummy student records to delete...")
        for i in range(0, len(students), BATCH_SIZE):
            subset = students[i:i+BATCH_SIZE]
            subset.sudo().unlink()
            cr.commit()
            print(f"Deleted {i+len(subset)} student records...")

        # Delete dummy student users (student1–student10000)
        student_users = env['res.users'].search([
            ('login', 'like', 'student%'),
            ('email', 'like', '%@st.futminna.edu.ng'),
        ])
        print(f"Found {len(student_users)} dummy student users to delete...")
        for i in range(0, len(student_users), BATCH_SIZE):
            subset = student_users[i:i+BATCH_SIZE]
            subset.sudo().unlink()
            cr.commit()
            print(f"Deleted {i+len(subset)} student users...")

        # Delete dummy faculty users (faculty0–faculty499)
        faculty_users = env['res.users'].search([
            ('login', 'like', 'faculty%'),
            ('email', 'like', '%@st.futminna.edu.ng'),
        ])
        print(f"Found {len(faculty_users)} dummy faculty users to delete...")
        for i in range(0, len(faculty_users), BATCH_SIZE):
            subset = faculty_users[i:i+BATCH_SIZE]
            subset.sudo().unlink()
            cr.commit()
            print(f"Deleted {i+len(subset)} faculty users...")

        # Delete op.faculty created for dummy users (guarded by domain)
        faculties = env['op.faculty'].search([
            ('email', 'like', '%@st.futminna.edu.ng'),
        ])
        print(f"Found {len(faculties)} dummy faculty records to delete...")
        for i in range(0, len(faculties), BATCH_SIZE):
            subset = faculties[i:i+BATCH_SIZE]
            subset.sudo().unlink()
            cr.commit()
            print(f"Deleted {i+len(subset)} faculty records...")

        # Delete custom groups & category created by your script (small sets)
        env['res.groups'].search([('name', 'in', ['FUTMINNA / Student','FUTMINNA / Faculty'])]).sudo().unlink()
        env['ir.module.category'].search([('name', '=', 'FUTMINNA Roles')]).sudo().unlink()
        env['op.category'].search([('name', 'in', [
            "Electrical Engineering", "Mechanical Engineering", "Computer Science",
            "Architecture", "Biochemistry", "Physics", "Agriculture", "Cybersecurity",
            "Urban Planning", "Business Education"
        ])]).sudo().unlink()

        cr.commit()
        print("Cleanup complete: dummy students 1–10000 and faculty 0–499 removed.")

    except Exception as e:
        cr.rollback()
        print(f"Fatal error during cleanup: {e}")
        raise
