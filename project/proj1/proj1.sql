-- COMP9311 18s1 Project 1
--
-- MyMyUNSW Solution Template
-- Q1: 
create or replace view Q1(unswid, name)
as
select people.unswid, people.name 
from students,course_enrolments,people where
students.stype='intl'and
course_enrolments.grade='HD'and
course_enrolments.student=students.id and 
course_enrolments.student=people.id 

group by people.unswid , people.name having count(people.unswid)>20;

--... SQL statements, possibly using other views/functions defined by you ...
-- Q2: 
create or replace view Q2(unswid, name)
as
select rooms.unswid,rooms.longname
from buildings,rooms,room_types where  
room_types.description='Meeting Room' and 
buildings.name='Computer Science Building'
and rooms.capacity>=20 and rooms.capacity is not null
and rooms.building=buildings.id and rooms.rtype=room_types.id
--... SQL statements, possibly using other views/functions defined by you ...
;
-- Q3: 
create or replace view Q3(unswid, name)
as
select people.unswid,people.name
from people
where people.id in 
	(select course_staff.staff
	from people,course_enrolments,course_staff
	where people.name = 'Stefan Bilek' and 
	people.id = course_enrolments.student 
	and course_enrolments.course = course_staff.course);
--... SQL statements, possibly using other views/functions defined by you ...

-- Q4:
create or replace view Q4(unswid, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
select people.unswid,people.name 
from people,subjects,courses,Course_enrolments
where people.id not in 
(select people.id from subjects,courses,Course_enrolments,people
where courses.id=Course_enrolments.course and people.id=Course_enrolments.student
and courses.subject=subjects.id and subjects.code='COMP3231')
and subjects.code = 'COMP3331' and courses.id=Course_enrolments.course and 
courses.subject=subjects.id and Course_enrolments.student=people.id;

-- Q5: 
create or replace view Q5a(num)
as
select count(distinct program_enrolments.id)
	from semesters, program_enrolments,students,streams,stream_enrolments
		where semesters.year='2011' and semesters.term='S1' 
		and streams.name='Chemistry'and students.stype='local' 
		and semesters.id=program_enrolments.semester
		and students.id=program_enrolments.student
		and semesters.id=program_enrolments.semester
		and program_enrolments.id=stream_enrolments.partof
		and stream_enrolments.stream=streams.id
		and streams.id=stream_enrolments.stream
		--group by program_enrolments.id
		;
--... SQL statements, possibly using other views/functions defined by you ...
-- Q5: 
create or replace view Q5b(num)
as
select COUNT(Program_enrolments.id)
from Semesters,Programs,Program_enrolments,OrgUnit_types,OrgUnits,students
where Semesters.year='2011' and semesters.term='S1'
and students.stype='intl'
and OrgUnit_types.name='School' 
and OrgUnits.longname='School of Computer Science and Engineering' 
and Programs.offeredby=OrgUnits.id 
and Program_enrolments.semester=Semesters.id 
and Program_enrolments.program=Programs.id
and program_enrolments.student=students.id
and OrgUnits.utype=OrgUnit_types.id 
;
--... SQL statements, possibly using other views/functions defined by you ...

-- Q6:
create or replace function
	Q6(text) returns text
as
$$
select CONCAT(code,' ',name,' ',uoc) as text from Subjects 
where code='COMP9311'
--... SQL statements, possibly using other views/functions defined by you ...
$$ language sql;

-- Q7: 
create or replace view Q7(code, name)
as
select programs.code,programs.name
	from students, programs,program_enrolments 
		where program_enrolments.student=students.id
		and program_enrolments.program=programs.id
group by programs.id 
having sum(case when students.stype='intl'then 1 else null end )*1.0/count(programs.id) >0.5
order by programs.code;
--... SQL statements, possibly using other views/functions defined by you ...
-- Q8:

create or replace view Q8_1(code, name, semester)
as
select subjects.code,subjects.name,semesters.name,avg(course_enrolments.mark)
	from subjects, semesters,course_enrolments,courses
		where course_enrolments.course=courses.id 
		and courses.semester=semesters.id
		and subjects.id=courses.subject 
	group by subjects.code,subjects.name,semesters.name
    having count(case when course_enrolments.mark is not null then courses.id end )>=15 	
    order by avg(course_enrolments.mark) desc

create or replace view Q8(code,name,semester)
as
select Q8_1.code,Q8_1.name,Q8_1.semester
from Q8_1
where avg=(select max(Q8_1.avg)from Q8_1)
group by Q8_1.code,Q8_1.name,Q8_1.semester;


--... SQL statements, possibly using other views/functions defined by you ...


-- Q9:
create or replace view Q9_1(id,school,starting) as
select People.id,OrgUnits.longname,Affiliations.starting
from Affiliations,OrgUnits,People,Staff_roles,OrgUnit_types,Staff
where Affiliations.orgUnit=OrgUnits.id and Affiliations.staff=staff.id and Affiliations.role=Staff_roles.id 
and People.id=Affiliations.staff and OrgUnit_types.id=OrgUnits.utype 
and Staff_roles.name='Head of School' and  Affiliations.ending is Null and Affiliations.isprimary='t' and OrgUnit_types.name='School';

create or replace view Q9(name,school,email,starting,num_subjects) as
select People.name,Q9_1.school,People.email,Q9_1.starting,count(distinct Subjects.code) as num_subjects
from Q9_1,Subjects,Course_staff,Courses,People
where  Course_staff.course=Courses.id  and subjects.id=courses.subject and Q9_1.id=Course_staff.staff and People.id=Q9_1.id
group by People.name,Q9_1.school,People.email,Q9_1.starting
having count(distinct Subjects.code)>0;




-- Q10:
--select id
create or replace view Q10_1(sub_id)
as
select subjects.id
from semesters,subjects,courses 
where substr(subjects.code,1,6) = 'COMP93' and semesters.year >= 2003 and semesters.year <= 2012
and subjects.id = courses.subject  and courses.semester = semesters.id
group by subjects.id having count(subjects.id) = 20
;
create or replace view Q10(code, name, year, s1_HD_rate, s2_HD_rate)
as
select subjects.code,subjects.name,substr(cast(semesters.year as varchar(5)),3,2) as year,
cast(1.0 * count(case when course_enrolments.mark >= 85 and semesters.term = 'S1' then course_enrolments.student end)
	/count(case when semesters.term = 'S1' then course_enrolments.student end) as numeric(4,2)) as s1_HD_rate,
cast(1.0 * count(case when course_enrolments.mark >= 85 and semesters.term = 'S2' then course_enrolments.student end)
	/count(case when semesters.term = 'S2' then course_enrolments.student end) as numeric(4,2)) as s2_HD_rate
from course_enrolments,courses,subjects,semesters,Q10_1
where courses.subject  = subjects.id and courses.semester = semesters.id
and course_enrolments.course = courses.id and subjects.id = Q10_1.sub_id
and semesters.year >= 2003 and semesters.year <= 2012 
and course_enrolments.mark >= 0
group by subjects.code,subjects.name,semesters.year
order by subjects.code
--... SQL statements, possibly using other views/functions defined by you ...
;