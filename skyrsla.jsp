<%@ page language="java" import="is.idega.idegaweb.golf.MemberDevelopment,
is.idega.idegaweb.golf.access.AccessControl,
is.idega.idegaweb.golf.entity.Group,
is.idega.idegaweb.golf.entity.Member,
is.idega.idegaweb.golf.entity.Union,
is.idega.idegaweb.golf.entity.UnionHome,
java.io.File,
java.io.FileWriter,
java.io.IOException,
java.sql.Connection,
java.sql.ResultSet,
java.sql.SQLException,
java.sql.Statement,
java.util.*,
com.idega.data.IDOLookup,
com.idega.presentation.Block,
com.idega.presentation.IWContext,
com.idega.presentation.Page,
com.idega.presentation.PresentationObject,
com.idega.presentation.Table,
com.idega.presentation.text.Link,
com.idega.presentation.text.Text,
com.idega.presentation.ui.DateInput,
com.idega.presentation.ui.DropdownMenu,
com.idega.presentation.ui.Form,
com.idega.presentation.ui.HeaderTable,
com.idega.presentation.ui.InterfaceObject,
com.idega.presentation.ui.SubmitButton,
com.idega.util.IWTimestamp
  "extends="com.idega.servlet.IWJSPPresentationServlet"
%>
<%
  Skyrsla L = new Skyrsla();
   IWContext iwc = getIWContext();
  add(getLinkTable(1,iwc));
  add(L);
%>
<%!

private Table getLinkTable(int menuNr,IWContext iwc){
   com.idega.idegaweb.IWBundle iwb = iwc.getIWMainApplication().getBundle("is.idega.idegaweb.golf");
   com.idega.idegaweb.IWResourceBundle iwrb  = iwb.getResourceBundle(iwc);

    int iUnionId = 0;
    if(iwc.getSession().getAttribute("union_id")!=null){
        String sUnionId = (String)iwc.getSession().getAttribute("union_id");
        iUnionId = Integer.parseInt(sUnionId);
    }
    Table T = new Table();
    Link link1 = new Link(iwrb.getImage(menuNr == 1?"/tabs/lists.gif":"/tabs/lists1.gif"),"/reports/index.jsp");
    Link link2 = new Link(iwrb.getImage(menuNr == 2?"/tabs/utskrift.gif":"/tabs/utskrift1.gif"),"/list/skyrsla.jsp");
    Link link3 =new Link(iwrb.getImage(menuNr == 3?"/tabs/specialreport.gif":"/tabs/specialreport1.gif"),"/list/tareport.jsp");
    T.setAlignment("center");
    T.add(link1,1,1);
    T.add(link2,1,1);
    if(iUnionId == 93 || iUnionId == 2012){
      T.add(link3,1,1);
      //T.add("mjög lengi í vinnslu",2,7);
    }
    return T;

  }

/**
*@author <a href="mailto:aron@idega.is">Aron Birkir</a>
*@version 1.0
*/
public class Skyrsla extends Block {

     private String sUnionID,unionName,unionAbbrev;
     private int iUnionID = 0;
     private Union union;
     private Member eMember;
     private String MenuColor,ItemColor,HeaderColor,OtherColor;
     private boolean isAdmin = false;
     private boolean isClubAdmin = false;
     private Hashtable PermissionHash;
     private int cellspacing = 1, cellpadding = 2;
     private String list_action = "";
     protected String styleAttribute = "font-size: 8pt";
     protected int fontSize = 2;
     protected boolean fontBold = false;
     protected String MiddleColor,LightColor,DarkColor,WhiteColor,TextFontColor,HeaderFontColor,IndexFontColor;


     public Skyrsla(){

       HeaderColor = "#336660";
       LightColor = "#CEDFD0";
       MiddleColor = "#9fA9B3";
       DarkColor = "#ADCAB1";
       OtherColor = "#6E9073 ";
       HeaderFontColor = DarkColor;
       TextFontColor = "#000000";
       IndexFontColor = "#000000";
       MenuColor="#ADCAB1";//,"#CEDFD0"
       ItemColor="#CEDFD0";//"#D0F0D0"
     }

     protected void control(IWContext iwc){
       try{
         if (iwc.getSessionAttribute("union_id") == null)
	     iwc.setSessionAttribute("union_id", "1");
         sUnionID = (String)  iwc.getSession().getAttribute("union_id");
         if(sUnionID!=null){ iUnionID = Integer.parseInt(sUnionID);
           this.iUnionID = Integer.parseInt(sUnionID);
           //add(sUnionID);
         }

         eMember = (Member)AccessControl.getMember(iwc);
         if(eMember !=null && getPermissionHash(iwc,eMember.getID())){

           if(PermissionHash.containsValue("administrator") ){
             isAdmin = true;
           }
           else if(PermissionHash.containsValue("club_admin")  ){
             isAdmin = true;
           }
         }

         if(iwc.getParameter("main")!= null)	{ doMain(iwc);}
         else if(iwc.getParameter("change")!= null){ doChange(iwc);}
         else if(iwc.getParameter("update")!= null){ doUpdate(iwc);}
         else if(iwc.getParameter("file")!= null){ doFile(iwc); }
         else if(iwc.getParameter("file2")!= null){ doFile2(iwc);}
         else if(iwc.getParameter("file3")!= null){ doFile3(iwc);}
         else if(iwc.getParameter("file5")!= null){ doFile5(iwc);}
         else if(iwc.getParameter("file6")!= null){ doFile6(iwc);}
         else{doMain(iwc);}
       }
       catch(SQLException S){	S.printStackTrace();	}
       }

       private boolean getMemberAccessGroups(IWContext iwc,int iMemberId)throws SQLException{
       Group[] group = eMember.getGroups();
       int iGroupLen = group.length;
       PermissionHash = new Hashtable(iGroupLen);
       for(int i = 0; i < iGroupLen ; i++){
         PermissionHash.put(new Integer(group[i].getID()),group[i].getName() );
         iwc.getRequest().setAttribute("rep_perm_hash",PermissionHash);
         return true;
       }
       return false;
     }

     private boolean getPermissionHash(IWContext iwc,int iMemberId)throws SQLException{
       if(iwc.getRequest().getParameter("rep_perm_hash") != null){
         PermissionHash = (Hashtable) iwc.getRequest().getAttribute("rep_perm_hash");
         return true;
       }
       else{
         return getMemberAccessGroups(iwc,iMemberId);
       }
       //return false;
     }


       private void doMain(IWContext iwc) throws SQLException {
         add(this.makeMainTable());
       }

       private void doChange(IWContext iwc) throws SQLException{

       }

       private void doUpdate(IWContext iwc) {

         String strClub,strActive,strAge;

         strClub = iwc.getRequest().getParameter("list_clubs" );
         strActive = iwc.getRequest().getParameter("list_active");
         strAge = iwc.getRequest().getParameter("list_age");
         int age = 0,club = 0;
         if(strClub != null){   club = Integer.parseInt(strClub); }
         if(strAge != null){   age = Integer.parseInt(strAge);}
         doSkyrsla1(club,age,strActive );
       }

       private void doFile(IWContext iwc){
         String strClub,strActive;
         strClub = iwc.getRequest().getParameter("list_clubs" );
         strActive = iwc.getRequest().getParameter("list_active");
         int club = 0;
         if(strClub != null){   club = Integer.parseInt(strClub); }
         doSkyrsla2(iwc,club,strActive );
       }

       private void doFile2(IWContext iwc){
         String strClub,strActive;
         strClub = iwc.getRequest().getParameter("list_clubs" );
         int club = 0;
         if(strClub != null){   club = Integer.parseInt(strClub); }
         doSkyrsla3(iwc,club );
       }

       private void doFile3(IWContext iwc){
         String strClub;
         strClub = iwc.getRequest().getParameter("list_clubs" );
         int club = 0;
         if(strClub != null){   club = Integer.parseInt(strClub); }
         doSkyrsla4(iwc,club );
       }

       private void doFile6(IWContext iwc){
         String strClub;
         String status;
         strClub = iwc.getRequest().getParameter("list_clubs" );
         status = iwc.getParameter("list_active");
         int club = 0;
         if(strClub != null){   club = Integer.parseInt(strClub);
         doSkyrsla6(club,status );
         }
       }

       private void doFile5(IWContext iwc){
         /** @todo :Til ladda frá Aron */
         String strClub;
         String status;
         strClub = iwc.getRequest().getParameter("list_clubs" );
         status = iwc.getParameter("list_active");
         int club = 0;
         if(strClub != null){   club = Integer.parseInt(strClub); }
         else { club = 3; }
         String sDateFrom = iwc.getParameter("date_from");
         String sDateTo = iwc.getParameter("date_to");

         IWTimestamp dateBefore = null;
         if ( sDateFrom != null || sDateFrom.length() > 0 ) {
           dateBefore = new IWTimestamp(sDateFrom);
         }

         IWTimestamp dateAfter = null;
         if ( sDateTo != null || sDateTo.length() > 0 ) {
           dateAfter = new IWTimestamp(sDateTo);
         }

         MemberDevelopment memberDevelopment = null;
         if ( dateAfter == null && dateBefore != null ) {
           memberDevelopment = new MemberDevelopment(club,dateBefore);
         }
         else if ( dateBefore == null ) {
           memberDevelopment = new MemberDevelopment(club);
         }
         else {
           memberDevelopment = new MemberDevelopment(club,dateBefore,dateAfter);
         }

         if (status != null) {
   	if (status.equals("A")) {
   	  memberDevelopment.setOnlyActive();
   	}else if (status.equals("I")) {
   	  memberDevelopment.setOnlyInActive();
   	}
         }
         add(memberDevelopment);
       }

       private String getSQLA(String name,int unionid,int age,String gender,boolean olderthan,String active){
         IWTimestamp dateToday = new IWTimestamp(IWTimestamp.getTimestampRightNow());
         int thisYear = dateToday.getYear();
         int year = thisYear - age;
         StringBuffer sql = new StringBuffer("select count(member.member_id) ");
         sql.append(name);
         sql.append(" from union_member_info umi,member where member.member_id = umi.member_id ");
         if(unionid > 0){
           sql.append(" and union_id = ");
           sql.append(unionid);
         }
         sql.append(" and umi.membership_type = 'main' " );
         sql.append(" and member.date_of_birth ");
         sql.append(olderthan?"<":">=");
         sql.append(" '");
         sql.append(year);
         sql.append("-01-01'");
         sql.append(" and member_status = '");
         sql.append(active);
         sql.append("'");
         if(gender.equalsIgnoreCase("M") || gender.equalsIgnoreCase("F")){
           sql.append(" and gender = '");
           sql.append(gender);
           sql.append("'");
         }
         //add(sql.toString());
         return sql.toString();
       }

       private String getBaseSql(String sActive){
         StringBuffer sql = new StringBuffer("select first_name,middle_name,last_name,social_security_number,street,street_number,code,city,abbrevation");
         sql.append(" from member,address,member_address,zipcode,union_member_info,union_ ");
         sql.append(" where member.member_id = union_member_info.member_id ");
         sql.append(" and union_.union_id = union_member_info.union_id ");
         sql.append(" and member.member_id = member_address.member_id ");
         sql.append(" and address.address_id = member_address.address_id ");
         sql.append(" and zipcode.zipcode_id = address.zipcode_id ");
         sql.append(" and union_member_info.member_status = '" );
         sql.append(sActive);
         sql.append("'");
         sql.append(" and union_member_info.union_id = ");
         //System.err.println(sql.toString());
         return sql.toString();
       }

       private String getSQLB(int iUnionId,String sActive){
         StringBuffer sql = new StringBuffer(getBaseSql(sActive));
         sql.append(iUnionId);
         sql.append(" order by union_member_info.union_id,member.first_name,member.middle_name,member.last_name ");
         System.err.println(sql.toString());
         return sql.toString();
       }

        private String getSQLC(int iUnionId){
         StringBuffer sql = new StringBuffer();
         sql.append(" select first_name,middle_name,last_name,social_security_number social, ");
         sql.append(" street,code,city,substr(mi.handicap,1,5) handicap,sum(p.price)-balance tariff, ");
         sql.append(" sum(p.price) paid,balance status ,pt.name ptype ");
         sql.append(" from member m,member_address ma, ");
         sql.append(" address ad,member_info mi, ");
         sql.append(" zipcode z,account ac,payment p, payment_type pt, ");
         sql.append(" union_member_info umi ");
         sql.append(" where umi.member_id = m.member_id ");
         sql.append(" and m.member_id = ma.member_id ");
         sql.append(" and ma.address_id = ad.address_id ");
         sql.append(" and umi.payment_type_id = pt.payment_type_id ");
         sql.append(" and z.zipcode_id = ad.zipcode_id ");
         sql.append(" and ac.union_id = umi.union_id ");
         sql.append(" and ac.member_id = m.member_id ");
         sql.append(" and p.member_id = m.member_id ");
         sql.append(" and mi.member_id = m.member_id ");
         sql.append(" and umi.member_status like 'A' ");
         sql.append(" and umi.union_id = ");
         sql.append(iUnionId);
         sql.append(" group by  code,city,street,first_name,middle_name,last_name,social_security_number , ");
         sql.append(" mi.handicap,balance ,pt.name ");
         System.err.println(sql.toString());
         return sql.toString();
       }

       private String getSQLD(int iUnionId){
         StringBuffer sql = new StringBuffer();
         sql.append(" select distinct social_security_number,first_name,middle_name,last_name,street,code,city,abbrevation,userid ");
         sql.append(" from member m ,union_member_info,union_,userid,member_address ma,address ad,zipcode z ");
         sql.append(" where member.member_id = union_member_info.member_id ");
         sql.append(" and userid.member_id = m.member_id ");
         sql.append(" and m.member_id = ma.member_id ");
         sql.append(" and ma.address_id = ad.address_id ");
         sql.append(" and z.zipcode_id = ad.zipcode_id ");
         sql.append(" and union_.union_id = union_member_info.union_id ");
         sql.append(" and union_member_info.member_status = 'A' ");
         sql.append(" and union_member_info.union_id = " );
         sql.append(iUnionId);
         sql.append(" order by first_name,last_name ");
         System.err.println(sql.toString());
         return sql.toString();
       }
       private void doSkyrsla1(int iUnionId,int iAge,String sActive){
         Union[] u = new Union[0];

         try{
           int Ulen = 0;
           boolean all = false;
           if(iUnionId > -1){
             if(iUnionId == 0 ){
               u = getUnions();
               Ulen = u.length;
             }
             else {
               u = getUnion(iUnionId);
               Ulen = u.length;
             }
           }
           else{
             all = true;
             Ulen = 1;
           }

           int TableLen = Ulen+3;
           Table T = new Table(9,TableLen);
           T.setWidth("100%");
           T.setColumnAlignment(2,"center");
           T.setColumnAlignment(3,"right");
           T.setColumnAlignment(4,"right");
           T.setColumnAlignment(5,"right");
           T.setColumnAlignment(6,"right");
           T.setColumnAlignment(7,"right");
           T.setColumnAlignment(8,"right");
           T.setColumnAlignment(9,"right");
           T.setHorizontalZebraColored(DarkColor,LightColor);
           T.add("Klúbbur",1,1);
           T.add("Fjöldi karla " + iAge +" ára og yngri",3,1);
           T.add("Fjöldi kvenna " + iAge +" ára og yngri",4,1);
           T.add("Fjöldi karla" + (iAge+1)+ "ára og eldri",5,1);
           T.add("Fjöldi kvenna" + (iAge+1)+ "ára og eldri",6,1);
           T.add("Fjöldi karla",7,1);
           T.add("Fjöldi kvenna",8,1);
           T.add("Samtals fjöldi",9,1);
           int totalA = 0, totalB = 0, totalC = 0, totalD = 0, totalE = 0, totalF = 0, totalG = 0;
           for(int i = 0; i < Ulen ; i++){
             int Unid = -1;
             if(!all){
             T.add(u[i].getName(),1,i+2);
             T.add(u[i].getAbbrevation(),2,i+2);
             Unid = u[i].getID();
             }

             try{
               int countA = getCount(getSQLA("total",Unid,iAge,"M",false,sActive),"total");
               T.add(String.valueOf(countA),3,i+2);

               int countB = getCount(getSQLA("total",Unid,iAge,"F",false,sActive),"total");
               T.add(String.valueOf(countB),4,i+2);

               int countC = getCount(getSQLA("total",Unid,iAge,"M",true,sActive),"total");
               T.add(String.valueOf(countC),5,i+2);

               int countD = getCount(getSQLA("total",Unid,iAge,"F",true,sActive),"total");
               T.add(String.valueOf(countD),6,i+2);

               int countE = countA+countC;
               int countF = countB+countD;
               int countG = countF+countE;

               T.add(String.valueOf(countE),7,i+2);
               T.add(String.valueOf(countF),8,i+2);
               T.add(String.valueOf(countG),9,i+2);

               totalA += countA;
               totalB += countB;
               totalC += countC;
               totalD += countD;
               totalE += countE;
               totalF += countF;
               totalG += countG;
             }
             catch(Exception sql){
   		sql.printStackTrace();
   		add(" sql innri villa");
   		return;
   	}

           }

           T.add("Alls",1,TableLen);
           T.add(String.valueOf(totalA),3,TableLen);
           T.add(String.valueOf(totalB),4,TableLen);
           T.add(String.valueOf(totalC),5,TableLen);
           T.add(String.valueOf(totalD),6,TableLen);
           T.add(String.valueOf(totalE),7,TableLen);
           T.add(String.valueOf(totalF),8,TableLen);
           T.add(String.valueOf(totalG),9,TableLen);
           add(T);
         }
         catch(SQLException sql){add(" sql villa");}
         catch(Exception e){e.printStackTrace();add(e.toString());}

       }
       private void doSkyrsla2(IWContext iwc,int iUnionId,String sActive){
         IWTimestamp datenow = new IWTimestamp();
         String fileSeperator = System.getProperty("file.separator");
         String filepath = iwc.getServletContext().getRealPath(fileSeperator+"gsi/reports"+fileSeperator);
         StringBuffer fileName = new StringBuffer("skyrsla.");
         fileName.append(datenow.getDay());
         fileName.append(datenow.getMonth());
         fileName.append(".txt");

         String sWholeFileString = fileName.toString();
         String wholePath = fileSeperator+"gsi/reports"+fileSeperator+sWholeFileString;

         java.text.DecimalFormat df = new java.text.DecimalFormat("0000000000");
         try{
           String st = filepath+sWholeFileString;
           //add(st);
           File outputFile = new File(st);
           //PrintWriter out = iwc.getResponse().getWriter() ;
           FileWriter out = new FileWriter(outputFile);

           char[] c  = null;

           Connection Conn = com.idega.util.database.ConnectionBroker.getConnection();
           Statement stmt = Conn.createStatement();
           ResultSet RS = null;

           Union[] U = new Union[0];
           boolean isOnlyClub = false;

           if(iUnionId == 1)
             U = getUnions();
           else {
             U = getUnion(iUnionId);
             isOnlyClub = true;
           }
           int Ulen = U.length;
           int unid;
           int count = 0;
           StringBuffer data = new StringBuffer();
           data.append("Nafn"); data.append("\t");
           data.append("Kennitala");data.append("\t");
           data.append("Heimili"); data.append("\t");
           data.append("Póstfang"); data.append("\t");
           data.append("Klúbbur"); data.append("\t");
           data.append("\n");
           out.write(data.toString().toCharArray());
           for(int i = 0; i < Ulen; i++){
             unid = U[i].getID();
             String sql = getSQLB(unid,sActive);
             RS = stmt.executeQuery(sql);
             while(RS.next()){
               data = new StringBuffer();
               String s = RS.getString(1); // first_name
               if(!RS.wasNull()){   data.append(s);       data.append(" ");     }
               s = RS.getString(2); // middle_name
               if(!RS.wasNull()){   data.append(s);       data.append(" ");     }
               s = RS.getString(3); // last_name
               if(!RS.wasNull()){   data.append(s); }
               data.append("\t");
               s = RS.getString(4); // Socialnumber
               if(!RS.wasNull()){   data.append(s); }
               data.append("\t");
               s = RS.getString(5); // Street
               if(!RS.wasNull()){   data.append(s);       data.append(" ");     }
               s = RS.getString(6); // Street_number
               //if(!RS.wasNull()){   data.append(s); }
               data.append("\t");
               s = RS.getString(7); // zipcode
               if(!RS.wasNull()){   data.append(s);       data.append(" ");     }
               s = RS.getString(8); // city
               if(!RS.wasNull()){   data.append(s); }
               data.append("\t");
               s = RS.getString(9); // abbreviaton
               if(!RS.wasNull()){   data.append(s);            }
               data.append("\n");
               c = data.toString().toCharArray();
               out.write(c);
               count++;
             }
           }
           if(RS!=null)
             RS.close();
           stmt.close();
           if(c!=null)
             out.write(c);
           com.idega.util.database.ConnectionBroker.freeConnection(Conn);
           out.close();

           Page page = Page.getPage(iwc);
           page.setToRedirect("/servlet/Excel?&dir="+st,1);

           Text T = new Text("Fjöldi færslna : "+count);
           /*Link L = new Link(new Text("Skýrsla"),listWindow);
           L.setURL("/excell");
           L.addParameter("dir",st);
           */
           add(makeMainTable());
           add("<br>");
           add(makeSubTable(T,new Text()));
         }
         catch(IOException io){add("io villa");}
         catch(SQLException sql){add("sql villa");sql.printStackTrace();}

       }

        private void doSkyrsla3(IWContext iwc,int iUnionId){
         IWTimestamp datenow = new IWTimestamp();
         String fileSeperator = System.getProperty("file.separator");
         String filepath = iwc.getServletContext().getRealPath(fileSeperator+"gsi/reports"+fileSeperator);
         StringBuffer fileName = new StringBuffer("skyrsla.");
         fileName.append(datenow.getDay());
         fileName.append(datenow.getMonth());
         fileName.append(".txt");

         String sWholeFileString = fileName.toString();
         String wholePath = fileSeperator+"gsi/reports"+fileSeperator+sWholeFileString;

         java.text.DecimalFormat df = new java.text.DecimalFormat("0000000000");
         try{
           String st = filepath+sWholeFileString;
           //add(st);
           File outputFile = new File(st);
           //PrintWriter out = iwc.getResponse().getWriter() ;
           FileWriter out = new FileWriter(outputFile);

           char[] c  = null;

           Connection Conn = com.idega.util.database.ConnectionBroker.getConnection();
           Statement stmt = Conn.createStatement();
           ResultSet RS = null;

           Union[] U = new Union[0];
           boolean isOnlyClub = false;

           if(iUnionId == 1)
             U = getUnions();
           else {
             U = getUnion(iUnionId);
             isOnlyClub = true;
           }
           int Ulen = U.length;
           int unid;
           int count = 0;
                   /*
           1 first_name,
           2 middle_name,
           3 last_name,
           4 social,
           5 street,
           6 code,
           7 city,
           8 handicap,
           9 paid,
           10 status ,
           11 tariff,
           12 ptype
           */
           StringBuffer data = new StringBuffer();
           data.append("Nafn"); data.append("\t");
           data.append("Kennitala");data.append("\t");
           data.append("Heimili"); data.append("\t");
           data.append("Póstfang"); data.append("\t");
           data.append("Forgjöf"); data.append("\t");
           data.append("Álagt"); data.append("\t");
           data.append("Greitt"); data.append("\t");
           data.append("Staða"); data.append("\t");
           data.append("Gerð"); data.append("\t");
           data.append("\n");
           out.write(data.toString().toCharArray());
           for(int i = 0; i < Ulen; i++){
             unid = U[i].getID();
             String sql = getSQLC(unid);
             RS = stmt.executeQuery(sql);
             while(RS.next()){
               data = new StringBuffer();
               String s = RS.getString(1); // first_name
               if(!RS.wasNull()){   data.append(s);       data.append(" ");     }
               s = RS.getString(2); // middle_name
               if(!RS.wasNull()){   data.append(s);       data.append(" ");     }
               s = RS.getString(3); // last_name
               if(!RS.wasNull()){   data.append(s); }
               data.append("\t");
               s = RS.getString(4); // Socialnumber
               if(!RS.wasNull()){   data.append(s); }
               data.append("\t");
               s = RS.getString(5); // Street
               if(!RS.wasNull()){   data.append(s);       data.append(" ");     }
               data.append("\t");
               s = RS.getString(6); // zipcode
               if(!RS.wasNull()){   data.append(s);       data.append(" ");     }
               s = RS.getString(7); // city
               if(!RS.wasNull()){   data.append(s); }
               data.append("\t");
               s = RS.getString(8); // handicap
               if(!RS.wasNull()){   data.append(s); }
               data.append("\t");
               s = RS.getString(9); // tariffs
               if(!RS.wasNull()){   data.append(s); }
               data.append("\t");
               s = RS.getString(10); // paid
               if(!RS.wasNull()){   data.append(s); }
               data.append("\t");
               s = RS.getString(11); // balance
               if(!RS.wasNull()){   data.append(s); }
               data.append("\t");
               s = RS.getString(12); // paytype
               if(!RS.wasNull()){   data.append(s); }
               data.append("\n");
               c = data.toString().toCharArray();
               out.write(c);
               count++;
             }
           }
           if(RS!=null)
             RS.close();
           stmt.close();
           if(c!=null)
             out.write(c);
           com.idega.util.database.ConnectionBroker.freeConnection(Conn);
           out.close();

           Page page = Page.getPage(iwc);
           page.setToRedirect("/servlet/Excel?&dir="+st,1);

           Text T = new Text("Fjöldi færslna : "+count);
           /*Link L = new Link(new Text("Skýrsla"),listWindow);
           L.setURL("/excell");
           L.addParameter("dir",st);
           */
           add(makeMainTable());
           add("<br>");
           add(makeSubTable(T,new Text()));
         }
         catch(IOException io){add("io villa");}
         catch(SQLException sql){add("sql villa");sql.printStackTrace();}

       }

       private void doSkyrsla4(IWContext iwc,int iUnionId){
         IWTimestamp datenow = new IWTimestamp();
         String fileSeperator = System.getProperty("file.separator");
         String filepath = iwc.getServletContext().getRealPath(fileSeperator+"gsi/reports"+fileSeperator);
         StringBuffer fileName = new StringBuffer("usid.");
         fileName.append(datenow.getDay());
         fileName.append(datenow.getMonth());
         fileName.append(".txt");

         String sWholeFileString = fileName.toString();
         String wholePath = fileSeperator+"gsi/reports"+fileSeperator+sWholeFileString;

         java.text.DecimalFormat df = new java.text.DecimalFormat("0000000000");
         try{
           String st = filepath+sWholeFileString;
           //add(st);
           File outputFile = new File(st);
           //PrintWriter out = iwc.getResponse().getWriter() ;
           FileWriter out = new FileWriter(outputFile);

           char[] c  = null;

           Connection Conn = com.idega.util.database.ConnectionBroker.getConnection();
           Statement stmt = Conn.createStatement();
           ResultSet RS = null;

           Union[] U = new Union[0];
           boolean isOnlyClub = false;

           add(""+iUnionId);

           if(iUnionId == 0)
             U = getUnions();
           else {
             U = getUnion(iUnionId);
             isOnlyClub = true;
           }
           int Ulen = U.length;
           int unid;
           int count = 0;
           StringBuffer data = new StringBuffer();

           data.append("Kennitala");data.append("\t");
           data.append("Nafn"); data.append("\t");
           data.append("Klúbbur"); data.append("\t");
           data.append("Auðkenni"); data.append("\t");
           data.append("\n");
           out.write(data.toString().toCharArray());
           for(int i = 0; i < Ulen; i++){
             unid = U[i].getID();
             String sql = getSQLD(unid);
             RS = stmt.executeQuery(sql);
             while(RS.next()){
               //social_security_number,first_name,middle_name,last_name,abbrevation,userid
               data = new StringBuffer();
               String s;
               s = RS.getString(1); // Socialnumber
               if(!RS.wasNull()){   data.append(s); }
               data.append("\t");
               s = RS.getString(2);
               if(!RS.wasNull()){   data.append(s);       data.append(" ");     }
               s = RS.getString(3); // middle_name
               if(!RS.wasNull()){   data.append(s);       data.append(" ");     }
               s = RS.getString(4); // last_name
               if(!RS.wasNull()){   data.append(s); }
               data.append("\t");
               s = RS.getString(5); // Street
               if(!RS.wasNull()){   data.append(s);       data.append(" ");     }
               data.append("\t");
               s = RS.getString(6); // zipcode
               if(!RS.wasNull()){   data.append(s);       data.append(" ");     }
               s = RS.getString(7); // city
               if(!RS.wasNull()){   data.append(s); }
               data.append("\t");
               s = RS.getString(8); // abbrevation
               if(!RS.wasNull()){   data.append(s); }
               data.append("\t");
               s = RS.getString(9); // userid
               if(!RS.wasNull()){   data.append(s);            }
               data.append("\n");
               c = data.toString().toCharArray();
               out.write(c);
               count++;
             }
           }
           if(RS!=null)
             RS.close();
           stmt.close();
           if(c!=null)
             out.write(c);

           com.idega.util.database.ConnectionBroker.freeConnection(Conn);
           out.close();

           Page page = Page.getPage(iwc);
           page.setToRedirect("/servlet/Excel?&dir="+st,1);

           Text T = new Text("Fjöldi færslna : "+count);
           /*Link L = new Link(new Text("Skýrsla"),listWindow);
           L.setURL("/excell");
           L.addParameter("dir",st);
           */
           add(makeMainTable());
           add("<br>");
           add(makeSubTable(T,new Text()));
         }
         catch(IOException io){add("io villa");}
         catch(SQLException sql){add("sql villa");}

       }

       private String[] getUnionMemberEmails(int iUnionId, String status){
         StringBuffer sql = new StringBuffer("select m.email ");
         sql.append(" from member m , union_member_info umi ");
         sql.append(" where m.email is not null ");
         sql.append(" and m.email != '' ");
         sql.append(" and umi.member_id = m.member_id ");
         sql.append(" and umi.union_id =");
         sql.append(iUnionId);
         sql.append(" and umi.member_status = '");
         sql.append(status);
         sql.append("'");
        try {
          return com.idega.data.SimpleQuerier.executeStringQuery(sql.toString());
        }
        catch (Exception ex) {

        }
        return null;
       }

       private void doSkyrsla6(int iUnionId,String status){
           String[] emails = getUnionMemberEmails(iUnionId,status);
           Table T = new Table();
           T.setWidth("300");
           if(emails !=null && emails.length > 0){
             StringBuffer sEmails = new StringBuffer();
             String sBreak = "<br>";
             for (int i = 0; i < emails.length; i++) {
               sEmails.append(emails[i]);
               sEmails.append(";");
               //if(i%6 == 0)
                 sEmails.append(sBreak);
             }
             T.add(sEmails.toString());
           }
           else
             T.add("Engin netföng skráð",9,1);

         add(T);
       }
   /*
       private String format(String s,int length,String fillup,boolean front){
         char[] charArray = new char[length];
         if(front && s.length < length){
           while()
         }
         else{

         }


       }
     */

       private int getCount(String sql,String name)throws SQLException{
        /*
         Connection Conn = com.idega.util.database.ConnectionBroker.getConnection();
         Statement stmt = Conn.createStatement();
         ResultSet RS = stmt.executeQuery(sql);
         int count = 0;
         while(RS.next()){
           count = RS.getInt(1);
           add(""+count);
         }
         RS.close();
         stmt.close();
         */
         int count = -1;
         //count = new Union().getNumberOfRecords(sql);
         try {
           count = ((Union)IDOLookup.getHome(Union.class)).getNumberOfRecords(sql);
         } catch (Exception e) {
             e.printStackTrace();
         }
         return count;

       }
   /*
       private void makeFile(){
         Union U = new Union(iUnionId);
         IWTimestamp datenow = new IWTimestamp();
         String sLowerCaseUnionAbbreviation = U.getAbbrevation().toLowerCase();

         String fileSeperator = System.getProperty("file.separator");
         String filepath = iwc.getServletContext().getRealPath(fileSeperator+sLowerCaseUnionAbbreviation+fileSeperator);
         StringBuffer fileName = new StringBuffer(sLowerCaseUnionAbbreviation);
         fileName.append("skyrsla"+datenow.getDay()+datenow.getMonth()+".dat");

         String sWholeFileString = fileSeperator+fileName.toString();
         this.setFileLinkString(fileSeperator+sLowerCaseUnionAbbreviation+sWholeFileString);
         File outputFile = new File(filepath+sWholeFileString);
         FileWriter out = new FileWriter(outputFile);
         char[] c ;

         c = sb.toString().toCharArray();
         out.write(c);
         //out.close();
       }
   */

       private String getOrderByString(int key){
         String s;
         switch(key){
           case(1): s = "first_name,middle_name,last_name";  break;
           case(2): s = "social_security_number";              break;
           case(3): s = "street,street_number";               break;
           case(4): s = "number" ;                             break;
           case(5): s = "email" ;                              break;
           default: s = "first_name,middle_name,last_name";  break;
         }
         return s;
       }

        private String getTableString(int key){
         String s;
         switch(key){
           case(1): s = " member "; break;
           case(2): s = " member "; break;
           case(3): s = " address "; break;
           case(4): s = " phone " ; break;
           case(5): s = " member " ; break;
           default: s = " member "; break;
         }
          return s;
       }

        private String getWhereString(int key){
         String s;
         switch(key){
           case(1): s = " member "; break;
           case(2): s = " member "; break;
           case(3): s = " address "; break;
           case(4): s = " phone " ; break;
           case(5): s = " member " ; break;
           default: s = " member "; break;
         }
          return s;
       }
       private Table makeMainTable()throws SQLException{

         Table T = new Table(4,4);

         if(isAdmin){
           Table T2 = new Table();
           T2.setWidth(700);
           T2.setBorder(1);
           T2.add(addFirstReport(),1,2);
           T2.add(addSecondReport(),1,3);
           T2.add(addThirdReport(),1,4);
           T2.add(addFourthReport(),1,5);
           T2.add(addFifthReport(),1,6);
           T2.add(addSixthReport(),1,7);
           T.add(T2,2,2);
         }
         else
           T.add("Hefur ekki leyfi",2,3);
         return T;
     }

     private Table makeSubTable(PresentationObject msg1,PresentationObject msg2){

       Table T = new Table(4,4);
       T.setWidth("700");
       T.setWidth(1,"150");
       T.add("               ");
       T.add("<br><br><br>",2,2);
       if(isAdmin){
       HeaderTable HT = new HeaderTable();
       HT.setWidth(700);
       HT.setHeaderText("Skýrsla");
       HT.add("<br><br>");
       HT.add(msg1);
       HT.add("<br>");
       HT.add(msg2);
       HT.add("<br>");
       T.add(HT);
       }
       else
         T.add("Hefur ekki leyfi",2,3);
       return T;
     }
     private Form addFirstReport()throws SQLException{
         Form myform = new Form();
         myform.maintainAllParameters();
         Table T = new Table(1,2);
         Table T3 = new Table(2,1);
         T3.add(formatText("Skýrsla 1"),1,1);
         T3.add(formatText("Fjöldaskýrsla með aldurskiptingu (prentast á skjáinn)"),2,1);
         Table T2 = new Table(4,2);
         T2.add(formatText("Klúbbur"),1,1);
         T2.add(drpClubs(this.iUnionID == 1? getUnions():getUnion(this.iUnionID)),1,2);
         T2.add(formatText("Aldurskipting"),2,1);
         T2.add(drpAge(),2,2);
         T2.add(formatText("Virkir/Óvirkir"),3,1);
         T2.add(drpActive(),3,2);
         SubmitButton sb = new SubmitButton("update","Sækja");
         setStyle(sb);
         T2.add(sb,4,2);
         T.add(T3,1,1);
         T.add(T2,1,2);
         myform.add(T);
         return myform;

     }

     private Form addSecondReport()throws SQLException{
         Form myform = new Form();
         myform.maintainAllParameters();
         Table T = new Table(1,2);
         Table T3 = new Table(2,1);
         T3.add(formatText("Skýrsla 2"),1,1);
         T3.add("Heimilisföng klúbbmeðlima (Excel skjal)",2,1);
         Table T2 = new Table(4,2);
         T2.add("Klúbbur",1,1);

         T2.add(drpClubs(this.iUnionID == 1? getUnions():getUnion(iUnionID)),1,2);
         T2.add("Virkir/Óvirkir",2,1);
         T2.add(drpActive(),2,2);
         SubmitButton sb = new SubmitButton("file","Sækja");
         setStyle(sb);
         T2.add(sb,4,2);
         T.add(T3,1,1);
         T.add(T2,1,2);
         myform.add(T);
         return myform;
     }

     private Form addThirdReport()throws SQLException{
         Form myform = new Form();
         myform.maintainAllParameters();
         Table T = new Table(1,2);
         Table T3 = new Table(2,1);
         T3.add(formatText("Skýrsla 3"),1,1);
         T3.add(formatText("Heimilisföng og Skuldastaða  (Excel skjal) "),2,1);
         Table T2 = new Table(4,2);
         T2.add(formatText("Klúbbur"),1,1);
         T2.add(drpClubs(this.iUnionID == 1? getUnions():getUnion(iUnionID)),1,2);
         SubmitButton sb = new SubmitButton("file2","Sækja");
         setStyle(sb);
         T2.add(sb,4,2);
         T.add(T3,1,1);
         T.add(T2,1,2);
         myform.add(T);
         return myform;
     }

      private Form addFourthReport()throws SQLException{
         Form myform = new Form();
         myform.maintainAllParameters();
         Table T = new Table(1,2);
         Table T3 = new Table(2,1);
         T3.add(formatText("Skýrsla 4"),1,1);
         T3.add(formatText("félagar númer  (Excel skjal)  "),2,1);
         Table T2 = new Table(4,2);
         T2.add(formatText("Klúbbur"),1,1);
         T2.add(drpClubs(this.iUnionID == 1? getUnions():getUnion(iUnionID)),1,2);
         SubmitButton sb = new SubmitButton("file3","Sækja");
         setStyle(sb);
         T2.add(sb,4,2);
         T.add(T3,1,1);
         T.add(T2,1,2);
         myform.add(T);
         return myform;
     }

      private Form addFifthReport()throws SQLException{
         Form myform = new Form();
         myform.maintainAllParameters();
         Table T = new Table(1,2);
         Table T3 = new Table(2,1);
         T3.add(formatText("Skýrsla 5"),1,1);
         T3.add(formatText("Breytingar á forgjöf  (Excel skjal)  "),2,1);
         Table T2 = new Table(5,2);
         T2.add(formatText("Klúbbur"),1,1);
         T2.add(drpClubs(this.iUnionID == 1? getUnions():getUnion(iUnionID)),1,2);
         T2.add(formatText("Dags frá"),2,1);
         DateInput from = new DateInput("date_from",true);
         DateInput to = new DateInput("date_to",true);
         from.setYearRange(2004,2010);
         to.setYearRange(2004,2010);
         from.setYear(2004);
         to.setYear(2004);
         from.setStyle(this.styleAttribute);
         to.setStyle(this.styleAttribute);
         T2.add(from,2,2);
         T2.add(to,3,2);
         T2.add(formatText("Dags til"),3,1);
         T2.add("Virkir/Óvirkir",4,1);
         T2.add(drpActive(),4,2);
         SubmitButton sb = new SubmitButton("file5","Sækja");
         setStyle(sb);
         T2.add(sb,5,2);
         T.add(T3,1,1);
         T.add(T2,1,2);
         myform.add(T);
         return myform;
     }

     private Form addSixthReport()throws SQLException{
         Form myform = new Form();
         myform.maintainAllParameters();
         Table T = new Table(1,2);
         Table T3 = new Table(2,1);
         T3.add(formatText("Skýrsla 6"),1,1);
         T3.add(formatText("Netföng félaga ( á skjá)"),2,1);
         Table T2 = new Table(4,2);
         T2.add(formatText("Klúbbur"),1,1);
         T2.add(drpClubs(this.iUnionID == 1? getUnions():getUnion(iUnionID)),1,2);
         T2.add(formatText("Staða"),1,1);
         T2.add(drpActive(),1,2);
         SubmitButton sb = new SubmitButton("file6","Sækja");
         setStyle(sb);
         T2.add(sb,4,2);
         T.add(T3,1,1);
         T.add(T2,1,2);
         myform.add(T);
         return myform;
     }

     private Union[] getUnions() {
         Union[] u = null;
         try {
             u = (Union[])((Union) IDOLookup.instanciateEntity(Union.class)).findAllOrdered("abbrevation");
         } catch (Exception e) {
             System.out.println(e.getMessage());
         }
         return u;
       }
       
     private Union[] getUnion(int unionid) throws SQLException {
         Union[] u = new Union[1];
         try {
         	u[0] = ((UnionHome) IDOLookup.getHomeLegacy(Union.class)).findByPrimaryKey(unionid);
         } catch (Exception e) {
             System.out.println(e.getMessage());
         }
         return u;
       }

     private DropdownMenu drpClubs(Union[] unions){
       DropdownMenu drp = new DropdownMenu("list_clubs");
       int len = unions.length;
       if(len > 1)
         drp.addMenuElement("3","Allir");
       for(int i = 0; i < len; i++){
         drp.addMenuElement(unions[i].getID(),unions[i].getAbbrevation()+ " \t "+unions[i].getName());
       }
       drp.setSelectedElement(sUnionID);
       setStyle(drp);
       return drp;
     }

     private DropdownMenu drpAge(){
       DropdownMenu drp = new DropdownMenu("list_age");
       for(int i = 1; i < 120; i++){
         drp.addMenuElement(String.valueOf(i));
       }
       drp.setSelectedElement("15");
       setStyle(drp);
       return drp;
     }

     protected void setStyle(InterfaceObject O){
       O.setStyleAttribute(this.styleAttribute);
     }
      public Text formatText(String s){
       Text T= new Text();
       if(s!=null){
         T= new Text(s);
         if(this.fontBold)
         T.setBold();
         T.setFontColor(this.TextFontColor);
         T.setFontSize(this.fontSize);
       }
       return T;
     }
     public Text formatText(int i){
       return formatText(String.valueOf(i));
     }

     private DropdownMenu drpActive(){
       DropdownMenu drp = new DropdownMenu("list_active");
       drp.addMenuElement("A","Virkur");
       drp.addMenuElement("I","Óvirkur");
       setStyle(drp);
       return drp;
     }
     public void main(IWContext iwc){
       control(iwc);
     }
   }
%>
