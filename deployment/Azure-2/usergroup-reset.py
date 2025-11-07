import odoo

# Load Odoo config
odoo.tools.config.parse_config(['--config=/etc/odoo/odoo.conf'])
odoo.service.server.load_server_wide_modules()
registry = odoo.modules.registry.Registry.new('it2025')

with registry.cursor() as cr:
    env = odoo.api.Environment(cr, odoo.SUPERUSER_ID, {})

    portal_group = env.ref('base.group_portal')

    # --- Students ---
    students = env['res.users'].search([('login', 'ilike', 'student%')])
    for user in students:
        user.sudo().write({
            'groups_id': [(4, portal_group.id)],
            'password': 'student123'
        })
    print("Assigned {} student accounts to Portal group and reset passwords".format(len(students)))

    # --- Faculty ---
    faculty = env['res.users'].search([('login', 'ilike', 'faculty%')])
    for user in faculty:
        user.sudo().write({
            'groups_id': [(4, portal_group.id)],
            'password': 'staff123'
        })
    print("Assigned {} faculty accounts to Portal group and reset passwords".format(len(faculty)))

    cr.commit()
