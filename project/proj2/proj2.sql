--Q1:

drop type if exists RoomRecord cascade;
create type RoomRecord as (valid_room_number integer, bigger_room_number integer);

create or replace function Q1(course_id integer)
    returns RoomRecord
as $$
declare 
	rr RoomRecord;
begin
	case
		when (select count(id)from courses where id=$1)=0 then raise notice 'INVALTD COURSEID';
	return NULL;
	else
		select count(rooms.id)::integer into rr.valid_room_number from rooms
		where rooms.capacity>=(select count(*) from course_enrolments where course=course_id);
		select count(rooms.id)::integer
		into rr.bigger_room_number
		from rooms
		where rooms.capacity >=(select count(*) from course_enrolment_waitlist where course=course_id)+ (select count(*) from course_enrolments 
			where course=course_id);
		return rr;
	end case; 
end;
--... SQL statements, possibly using other views/functions defined by you ...
$$ language plpgsql;


--Q2:4
-- overrall table
create or replace view q2_1(staff,cid,term,code,name,uoc,mark,sequence,totalEnrols) as  -- create the overall table
	select course_staff.staff,course_staff.course,right(cast(semesters.year as varchar), 2)||lower(semesters.term) as term,
subjects.code, subjects.name, subjects.uoc,Course_enrolments.mark,
Row_NUMBER() over(partition by course_enrolments.course,staff.id,subjects.code order by course_enrolments.mark desc),
count(0) over (partition by courses.id,staff.id,subjects.code)
FROM courses,semesters,subjects,course_staff,Course_enrolments,staff
where  Course_enrolments.mark is not NULL and courses.semester = semesters.id 
and subjects.id = courses.subject
and course_enrolments.course = courses.id 
and staff.id=course_staff.staff
and course_staff.course= courses.id
order by staff.id,course_staff.course,semesters.term,Course_enrolments.mark desc;

drop type if exists TeachingRecord cascade;
create type TeachingRecord as (cid integer, term char(4), code char(8),name text,uoc integer,average_mark integer, 
							   highest_mark integer, median_mark integer, totalEnrols integer); 

create or replace function Q2(staff_id integer)
	returns setof TeachingRecord
as $$
declare Tr TeachingRecord;
begin
	case
		when (select count(staff.id) from staff where staff.id=$1) = 0 then raise exception 'INVALID STAFFID';
	else
		return query select q2_1.cid::integer,q2_1.term::char(4),q2_1.code::char(8),q2_1.name::text,
		q2_1.uoc::integer,round(avg(q2_1.mark))::integer,max(mark)::integer,
		round(avg(case when q2_1.sequence in ((q2_1.totalEnrols+1)/2,(q2_1.totalEnrols+2)/2) then q2_1.mark end))::integer,
		count(*)::integer
		from q2_1
		where q2_1.staff=$1
		group by q2_1.staff,q2_1.cid,q2_1.term,q2_1.code,q2_1.name,q2_1.uoc
		order by q2_1.term;
	end case;
end;
$$ language plpgsql;

--Q3:
--recursion
create or replace function Q3_1(org_id integer)
returns table(owner integer,member integer)
as $$
with recursive q as (select member,owner from orgunit_groups where member=$1
union all select m.member,m.owner from orgunit_groups m join q on q.member=m.owner)
select owner,member from q;
$$ language sql;
drop type if exists CourseRecord cascade;
create type CourseRecord as (unswid integer, student_name text, course_records text);

create or replace function Q3(org_id integer, num_courses integer, min_score integer)
  returns setof CourseRecord
as $$
--... SQL statements, possibly using other views/functions defined by you ...
$$ language plpgsql;