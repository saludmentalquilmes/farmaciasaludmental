-- Farmacia Salud Mental — esquema de base de datos para Supabase
-- Pegar todo este archivo en Supabase: Panel > SQL Editor > New query > Run

create extension if not exists "pgcrypto";

-- ---------- MEDICAMENTOS (vademecum) ----------
create table if not exists medicamentos (
  id uuid primary key default gen_random_uuid(),
  nombre text not null unique,
  unidad text not null default 'comprimidos',
  stock_actual integer not null default 0,
  stock_minimo integer not null default 0,
  creado_en timestamptz not null default now()
);

-- ---------- PACIENTES ----------
create table if not exists pacientes (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  dni text not null unique,
  telefono text default '',
  notas text default '',
  creado_en timestamptz not null default now()
);

-- ---------- MOVIMIENTOS (entradas, retiros, ajustes) ----------
create table if not exists movimientos (
  id uuid primary key default gen_random_uuid(),
  tipo text not null check (tipo in ('entrada', 'retiro', 'ajuste')),
  medicamento_id uuid references medicamentos(id),
  medicamento_nombre text not null,
  cantidad integer not null,
  fecha date not null,
  nota text default '',
  registrado_por text default '',
  paciente_id uuid references pacientes(id),
  paciente_nombre text,
  creado_en timestamptz not null default now()
);

create index if not exists idx_movimientos_paciente on movimientos(paciente_id);
create index if not exists idx_movimientos_fecha on movimientos(fecha);
create index if not exists idx_movimientos_medicamento on movimientos(medicamento_id);

-- ---------- SEGURIDAD: solo usuarios logueados (staff) pueden leer y escribir ----------
-- Nadie de afuera sin cuenta creada en el sistema puede ver ni tocar nada.
alter table medicamentos enable row level security;
alter table pacientes enable row level security;
alter table movimientos enable row level security;

create policy "staff_select_medicamentos" on medicamentos for select using (auth.role() = 'authenticated');
create policy "staff_insert_medicamentos" on medicamentos for insert with check (auth.role() = 'authenticated');
create policy "staff_update_medicamentos" on medicamentos for update using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "staff_select_pacientes" on pacientes for select using (auth.role() = 'authenticated');
create policy "staff_insert_pacientes" on pacientes for insert with check (auth.role() = 'authenticated');
create policy "staff_update_pacientes" on pacientes for update using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "staff_select_movimientos" on movimientos for select using (auth.role() = 'authenticated');
create policy "staff_insert_movimientos" on movimientos for insert with check (auth.role() = 'authenticated');

-- ---------- VADEMECUM INICIAL (mismo listado que ya usaban) ----------
insert into medicamentos (nombre, unidad, stock_actual, stock_minimo) values
  ('AMITRIPTILINA 25 MG COMP', 'comprimidos', 0, 200),
  ('ARIPIPRAZOL 10 MG. COMP', 'comprimidos', 8640, 200),
  ('ARIPIPRAZOL 15 MG. COMP', 'comprimidos', 1330, 200),
  ('BIPERIDENO 2 MG COMP', 'comprimidos', 21630, 200),
  ('BUPROPION', 'comprimidos', 0, 200),
  ('CARBAMAZEPINA 200 MG COMP', 'comprimidos', 54415, 200),
  ('CARBONATO DE LITIO 300 MG COMP', 'comprimidos', 0, 200),
  ('CARBONATO DE LITIO 450 MG COMP', 'comprimidos', 0, 200),
  ('CLOBAZAN', 'comprimidos', 0, 200),
  ('CLOMIPRAMINA 75 MG. COMP', 'comprimidos', 0, 200),
  ('CLONAZEPAM 0.5 MG COMP', 'comprimidos', 2370, 200),
  ('CLONAZEPAM 2 MG COMP', 'comprimidos', 129555, 200),
  ('CLOTIAPINA 40 MG COMP', 'comprimidos', 1560, 200),
  ('CLOZAPINA 100 MG COMP', 'comprimidos', 0, 200),
  ('DIAZEPAM 10 MG COMP', 'comprimidos', 8541, 200),
  ('DIVALP. DE SODIO 125 MG COMP', 'comprimidos', 0, 200),
  ('DIVALP. DE SODIO 250 MG COMP', 'comprimidos', 0, 200),
  ('DIVALP. DE SODIO 500 MG COMP', 'comprimidos', 77005, 200),
  ('ESCITALOPRAM 10 MG COMP', 'comprimidos', 35790, 200),
  ('FENITOINA 100 MG COMP', 'comprimidos', 0, 200),
  ('FENOBARBITAL 100 MG COMP', 'comprimidos', 0, 200),
  ('FLUOXETINA 20 MG COMP', 'comprimidos', 0, 200),
  ('HALOPERIDOL 5 MG COMP', 'comprimidos', 0, 200),
  ('HALOPERIDOL 10 MG COMP', 'comprimidos', 13950, 200),
  ('HALOPERIDOL DEC. 50 MG AMP', 'ampollas', 100, 10),
  ('HALOPERIDOL DEC. 150 MG AMP', 'ampollas', 0, 10),
  ('LAMOTRIGINA 50 MG. COMP', 'comprimidos', 0, 200),
  ('LAMOTRIGINA 100 MG. COMP', 'comprimidos', 0, 200),
  ('LEVOMEPROMAZINA 25 MG', 'comprimidos', 53955, 200),
  ('LORAZEPAM 2.5 MG COMP', 'comprimidos', 35520, 200),
  ('MEMANTINA 20 MG. COMP', 'comprimidos', 0, 200),
  ('METILFENIDATO 10MG COMP', 'comprimidos', 0, 200),
  ('OLANZAPINA 5 MG COMP', 'comprimidos', 0, 200),
  ('OLANZAPINA 10 MG COMP', 'comprimidos', 15400, 200),
  ('PREGABALINA 150 MG COMP', 'comprimidos', 0, 200),
  ('PREGABALINA 75 MG COMP', 'comprimidos', 0, 200),
  ('PROMETAZINA 25 MG', 'comprimidos', 7950, 200),
  ('QUETIAPINA 100 MG', 'comprimidos', 49880, 200),
  ('RISPERIDONA 1 MG COMP', 'comprimidos', 10740, 200),
  ('RISPERIDONA 2 MG COMP', 'comprimidos', 30300, 200),
  ('RISPERIDONA 3 MG COMP', 'comprimidos', 465, 200),
  ('SERTRALINA 50 MG COMP', 'comprimidos', 23285, 200),
  ('TIORIDAZINA 200 MG COMP', 'comprimidos', 0, 200),
  ('TIORIDAZINA 25 MG COMP', 'comprimidos', 0, 200),
  ('TOPIRAMATO 50 MG COMP', 'comprimidos', 0, 200),
  ('TOPIRAMATO 100 MG COMP', 'comprimidos', 0, 200),
  ('TRIFLUOPERAZINA 10 MG', 'comprimidos', 0, 200),
  ('TRIFLUOPERAZINA 5 MG', 'comprimidos', 0, 200),
  ('VALPROATO DE MG 200 MG COMP', 'comprimidos', 0, 200),
  ('VALPROATO DE MG 400 MG COMP', 'comprimidos', 375, 200),
  ('ZOLPIDEN 10 MG COMP', 'comprimidos', 850, 200)
on conflict (nombre) do nothing;
