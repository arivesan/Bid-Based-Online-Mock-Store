<%@ page import="java.lang.*"%>
<%// Import the package where the API is located%>
<%@ page import="ut.JAR.CPEN410FINALPROJECT.*"%>
<%// Import the java.sql package to use MySQL related methods %>
<%@ page import="java.sql.*"%>

<%
	// Perform the authentication process
	if((session.getAttribute("userName")==null) || (session.getAttribute("currentPage")==null)) {
		// delete session variables
		session.setAttribute("currentPage", null);
		session.setAttribute("userName", null);
		// return to the login page
		response.sendRedirect("login.jsp");
	} else {
		// Declare and define the current page, and get the
		// username and the previous page from the session variables
		String currentPage = "listUsers.jsp";
		String userName = session.getAttribute("userName").toString();
		String previousPage = session.getAttribute("currentPage").toString();
		
		// Try to connect the database using the applicationDBAuthentication class
		try {
			// Create the appDBAuth object
			applicationDBAuthentication appDBAuth = new applicationDBAuthentication();
			System.out.println("Connecting...");
			System.out.println(appDBAuth.toString());
				
			// Verify if the user has access to this page
			if(appDBAuth.verifyUserPageAccess(userName, currentPage)) {
				// The user have access to the current page
				// Verify that the user is following the page flow
				ResultSet res = appDBAuth.verifyUserPageFlow(userName, currentPage, previousPage);
				if(res.next()) {
					// the user was authenticated
					// Get the user complete name
					String userActualName = res.getString(3);
					
					// Create the current page attribute
					session.setAttribute("currentPage", "listUsers.jsp");
					
					//Create or update a session variable for the username
					if(session.getAttribute("userName")==null) {
						// create the session variable
						session.setAttribute("userName", userName);
					} else {
						// Update the session variable
						session.setAttribute("userName", userName);
					}
%>
					<!doctype html> 
					<html>
					    <head>
					    	<!--Define the encoding-->
					        <meta charset="utf-8">
					        <!--Define the authors of the page-->
					        <meta name="author" content="a-carrasquillo, arivesan">
					        <!--Import the style-sheet for page-->
					        <link rel="stylesheet" type="text/css" href="css/listUsers.css">
					        <!--Import the icon shown in the tab-->
					        <link rel="icon" type="image/x-icon" href="images/favicon.ico">
					        <!--Define the title of the page-->
					        <title>Heaven of Bids Administration</title>
					        <!-- Load icon library -->
					        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
					        <!--Script that allows us to show a message when the make inactive button is pressed and the user is already inactive-->
					        <script type="text/javascript">
					            function showMessage() {
					                alert("The User is already inactive!!!");
					            }
					        </script>
					    </head>
					    <body>
					        <div class="header">
					            <!--Small Bid Icon-->
					            <img class = "header_icon" src="images/BID.jpg"> 
					            <!--Left side clouds-->
					            <img class = "nube" id="nube1" src="images/nube.png">
					            <img class = "nube" id="nube2" src="images/nube.png">
					            <!--Central message-->
					            <h1>Welcome <%=userActualName%> to the Heaven of Bids</h1>
					            <!--Right side clouds-->
					            <img class = "nube" id="nube5" src="images/nube.png">
					            <img class = "nube" id="nube6" src="images/nube.png">
					            <img class = "nube" id="nube7" src="images/nube.png">
					            <img class = "nube" id="nube8" src="images/nube.png">
					        </div>
					        
					        <!--Logout/sign-out button-->
					        <button id ="logout" type="button" onclick="window.location.href='signout.jsp';">Sign out</button>

					        <div class = "left_side_square">
				            <!--Central message of the left side square-->
				            <h1>Administrator Operations</h1> 
				            <!--Options that the Administrator can choose from-->
<%
							// Bring the menu from the database based on the username
						   	res = appDBAuth.menuElements(userName);
							
							String previousTitle = "";
							// Verify that the result set is not empty
							if(!res.isAfterLast()) {
								// Iterate through the result set 
								while(res.next()) {
									// Verify that the title is different from the previous one
									if(!previousTitle.equals(res.getString(2))) {
%>
										<h2 class="optionClassTag"><%=res.getString(2)%>:</h2>
<%
									}
									// Verify if the current page is the same as
									// the one recover from the DB
									if(currentPage.equals(res.getString(1))) {
										// Since is the same page, remove the link
										// and set an active id
%>
										<button class="option" type="button" id="active"><%=res.getString(3)%></button>							
<%
									} else {
										// Since it's not the same page, get the link
										// to the page and do not use an active id
%>
										<button class="option" type="button" onclick="window.location.href='<%=res.getString(1)%>';"><%=res.getString(3)%></button>							
<%								
									}
									// update the previous title variable for the next iteration
									previousTitle = res.getString(2);
								}
							} else {
								System.out.println("The user does not have a menu option...");
								// Clear session variables
								session.setAttribute("currentPage", null);
								session.setAttribute("userName", null);
								// return to the login page
								response.sendRedirect("login.jsp");
							}
							// Create an instance of the class where the required
							// API methods are located
						    applicationDBManager appDBMnger = new applicationDBManager();
							System.out.println("Connecting...");
							System.out.println(appDBMnger.toString());
							// Define and initialize boolean variables that will help
							// determine which method of the API needs to be called
							Boolean allUsers=false, activeUsers=false, inactiveUsers=false;
							// If the filter is null, means that the administrator
							// wants to see all the users
							allUsers = session.getAttribute("filter")==null;
							if(allUsers) {
								res = appDBMnger.listAllUsers();
							} else {
								// Verify if the filter indicates active or inactive users
								activeUsers = session.getAttribute("filter").toString().trim().equals("active");
								inactiveUsers = session.getAttribute("filter").toString().trim().equals("inactive"); 
								if(activeUsers) {
									res = appDBMnger.listAllActiveUsers();
								} else if(inactiveUsers) {
									res = appDBMnger.listAllInactiveUsers();
								} else {
									// error in the session variable,
									// value not recognized
									// Clear session variables
									session.setAttribute("currentPage", null);
									session.setAttribute("userName", null);
									System.out.println("Error in the session variable \"filter\", value not recognized. Redirecting to login page...");
									// return to the login page
									response.sendRedirect("login.jsp");
								}
							}
%>
		        		</div>
		        		<img class = "background" src="images/Bids.png">
        
				        <div class = "right_side_square">
				            <!--User List Filter Section-->
				            <div class="filter">
				                <form action="usersFilter.jsp" method="post">
				                    <select name="search_filter" class="search_filter">
<%
										// Determine what filter was used
										if(allUsers) {
%>
											<option value="" selected>All Users</option>
					                        <option value="active">Active Users</option>
					                        <option value="inactive">Inactive Users</option>
<%
										} else if(activeUsers) {
%>
											<option value="">All Users</option>
					                        <option value="active" selected>Active Users</option>
					                        <option value="inactive">Inactive Users</option>
<%
										} else {
%>
											<option value="">All Users</option>
					                        <option value="active">Active Users</option>
					                        <option value="inactive" selected>Inactive Users</option>
<%
										}
%>			                  
				                    </select>
				                    <button type="submit" class="filter_button" title="Filter"><i class="fa fa-filter" aria-hidden="true"></i></button>
				                </form>
				            </div>
<%							
							// Verify if there are results for the user filter
							if(!res.next()) {
								// the result set is empty
%>
								<!--Error Message-->
            					<p id="error">No user found with the specified filter. Try another one...</p>
<%
							} else {
								// Reset the result set pointer
								res.beforeFirst();
%>
								<!--User List Section-->
            					<table>
<%
								// Determine which filter was used to
								// know which HTML code is needed
								if(allUsers) {
									// iterate over the result set
									while(res.next()) {
										// Verify if the user is active or inactive
										if(res.getString(2).equals("1")) {
											// user is active
%>
											<tr>
												<!--user username-->
												<td><%=res.getString(1)%></td>
												<td>
							                        <form action="modifyUser.jsp" method="post">
							                            <input type="hidden" name="userName" value="<%=res.getString(1)%>">
							                            <button type="submit" class="editButton" title="Edit User"><i class="fa fa-pencil"></i></button>
							                        </form>
							                    </td>
							                    <td>
							                        <form action="removeUser.jsp" method="post">
							                            <input type="hidden" name="userName" value="<%=res.getString(1)%>">
							                            <button type="submit" class="inactiveButton" title="Make User Inactive"><i class="fa fa-ban" aria-hidden="true"></i></button>
							                        </form>
							                    </td>
							                </tr>
<%
										} else {
											// user is inactive
%>
											<tr>
												<!--user username-->
												<td><%=res.getString(1)%></td>
												<td>
													<form action="modifyUser.jsp" method="post">
							                            <input type="hidden" name="userName" value="<%=res.getString(1)%>">
							                            <button type="submit" class="editButton" title="Edit User"><i class="fa fa-pencil"></i></button>
							                        </form>
												</td>
												<td>
							                        <button type="button" class="inactiveButton" title="User Already Inactive" onclick="return showMessage();"><i class="fa fa-ban" aria-hidden="true"></i></button>
							                    </td>
											</tr>
<%
										}
									}
								} else if(activeUsers) {
									// Iterate over the result set
									while(res.next()) {
%>
										<tr>
											<!--user username-->
											<td><%=res.getString(1)%></td>
											<td>
							                    <form action="modifyUser.jsp" method="post">
							                        <input type="hidden" name="userName" value="<%=res.getString(1)%>">
							                        <button type="submit" class="editButton" title="Edit User"><i class="fa fa-pencil"></i></button>
							                    </form>
							                </td>
							                <td>
							                    <form action="removeUser.jsp" method="post">
							                        <input type="hidden" name="userName" value="<%=res.getString(1)%>">
							                        <button type="submit" class="inactiveButton" title="Make User Inactive"><i class="fa fa-ban" aria-hidden="true"></i></button>
							                    </form>
							                </td>
							            </tr>
<%
									}
								} else {
									// Iterate over the result set
									while(res.next()) {
%>
										<tr>
											<!--user username-->
											<td><%=res.getString(1)%></td>
											<td>
							                    <form action="modifyUser.jsp" method="post">
							                        <input type="hidden" name="userName" value="<%=res.getString(1)%>">
							                        <button type="submit" class="editButton" title="Edit User"><i class="fa fa-pencil"></i></button>
							                    </form>
							                </td>
							            </tr>
<%
									}
								}
%>
						</table>
<%
							}
%>
							</div>
						</body>
					</html>
<%
					// Close the connection to the DB
					appDBMnger.close();
				} else {
					// the user can not be authenticated
					// Clear session variables
					session.setAttribute("currentPage", null);
					session.setAttribute("userName", null);
					// return to the login page
					response.sendRedirect("login.jsp");
				}
				// close the result set
				res.close();
				// Close the connection to the database
				appDBAuth.close();
			} else {
				// The user does not have access to the current page
				// Clear session variables
				session.setAttribute("currentPage", null);
				session.setAttribute("userName", null);
				// return to the login page
				response.sendRedirect("login.jsp");
			}
		} catch(Exception e) {
%>
			Nothing to show!
<%
			e.printStackTrace();
			// Clear session variables
			session.setAttribute("currentPage", null);
			session.setAttribute("userName", null);
			// return to the login page
			response.sendRedirect("login.jsp");
		} finally {
			System.out.println("");
		}
	}
%>