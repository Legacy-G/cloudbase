from faker import Faker
import random
import odoo
import odoo.tools.config
import odoo.modules.registry
import odoo.api

fake = Faker()

# Load Odoo config
odoo.tools.config.parse_config(['--config=odoo.conf'])
odoo.service.server.load_server_wide_modules()
registry = odoo.modules.registry.Registry.new('it2025')

with registry.cursor() as cr:
    env = odoo.api.Environment(cr, odoo.SUPERUSER_ID, {'no_check_group': True})

    try:
        # Portal group
        portal_group = env.ref('base.group_portal')

        # Existing references
        departments = env['op.department'].search([], limit=4)   # op_department_1-4
        courses = env['op.course'].search([], limit=41)          # op_course_1-41
        academic_years = env['op.academic.year'].search([], limit=6)
        academic_terms = env['op.academic.term'].search([], limit=16)

        # Create Students
        for i in range(1, 501):
            name = fake.name()
            email = f"student{i}@st.futminna.edu.ng"
            login = f"student{i}@st.futminna.edu.ng"
            password = "student123"

            dept = random.choice(departments)
            course = random.choice(courses)
            year = random.choice(academic_years)
            term = random.choice(academic_terms)

            # Create user
            user = env['res.users'].sudo().create({
                'name': name,
                'login': login,
                'password': password,
                'email': email,
                'tz': 'Africa/Lagos',  # persistent field from demo XML
                'groups_id': [(4, portal_group.id)],
                'dept_id': dept.id,
                'department_ids': [(4, dept.id)],
            })
            user.partner_id.sudo().write({'email': email})

            # Create student record
            student = env['op.student'].sudo().create({
                'user_id': user.id,
                'partner_id': user.partner_id.id,
                'name': name,
                'email': email,
                'gr_no': f"ROLL{i}",
            })

            # Link to course
            env['op.student.course'].sudo().create({
                'student_id': student.id,
                'course_id': course.id,
                'batch_id': False,  # optional if batches exist
                'roll_number': f"{100000+i}",
            })


            if i % 100 == 0:
                print(f"Created {i} students...")
                cr.commit()

        # --- Create Faculty ---
        for i in range(1, 501):
            name = fake.name()
            email = f"faculty{i}@st.futminna.edu.ng"
            login = f"faculty{i}@st.futminna.edu.ng"
            password = "staff123"

            dept = random.choice(departments)

            # Create user
            user = env['res.users'].sudo().create({
                'name': name,
                'login': login,
                'password': password,
                'email': email,
                'tz': 'Africa/Lagos',
                'groups_id': [(4, portal_group.id)],
                'dept_id': dept.id,
                'department_ids': [(4, dept.id)],
            })
            user.partner_id.sudo().write({'email': email})

            # Link to faculty record
            env['op.faculty'].sudo().create({
                'name': name,
                'email': email,
                'partner_id': user.partner_id.id,
                'main_department_id': dept.id,
            })

            if i % 100 == 0:
                print(f"Created {i} faculty...")
                cr.commit()

        cr.commit()
        print("Dummy data generation complete: 500 students + 500 faculty")

    except Exception as e:
        cr.rollback()
        print(f"Fatal error: {e}")
        raise
