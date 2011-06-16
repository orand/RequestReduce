﻿<%@ Application Language="C#" %>
<%@ Import Namespace="RequestReduce" %>
<%@ Import Namespace="RequestReduce.Module" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">

    private static StringBuilder errorBuffer = new StringBuilder();
    private static StringWriter traceBuffer = new StringWriter();
    
    void Application_Start(object sender, EventArgs e) 
    {
        RequestReduceModule.CaptureError(BuildErrorMessage);
        System.Diagnostics.Trace.AutoFlush = true;
        System.Diagnostics.Trace.Listeners.Add(new System.Diagnostics.TextWriterTraceListener(traceBuffer));
        RRTracer.Trace("Application Starting.");
    }

    private void BuildErrorMessage(Exception ex)
    {
        errorBuffer.AppendLine(ex.ToString());
        if(ex.InnerException != null)
            BuildErrorMessage(ex.InnerException);
    }

    void Application_End(object sender, EventArgs e) 
    {
        //  Code that runs on application shutdown

    }
        
    void Application_Error(object sender, EventArgs e) 
    { 
        // Code that runs when an unhandled error occurs

    }

    void Session_Start(object sender, EventArgs e) 
    {
        // Code that runs when a new session is started

    }

    void Session_End(object sender, EventArgs e) 
    {
        // Code that runs when a session ends. 
        // Note: The Session_End event is raised only when the sessionstate mode
        // is set to InProc in the Web.config file. If session mode is set to StateServer 
        // or SQLServer, the event is not raised.

    }
       
    void Application_BeginRequest(object sender, EventArgs e)
    {
        if (Request.QueryString["OutputError"] == null && Request.QueryString["OutputTrace"]==null) return;
        
        if (Request.QueryString["OutputError"] != null)
        {
            Response.Write(errorBuffer.ToString());
            errorBuffer.Remove(0, errorBuffer.Length);
        }
        if (Request.QueryString["OutputTrace"] != null)
        {
            Response.Write(traceBuffer);
            traceBuffer.Dispose();
            traceBuffer = new StringWriter();
            System.Diagnostics.Trace.Listeners.Clear();
            System.Diagnostics.Trace.Listeners.Add(new System.Diagnostics.TextWriterTraceListener(traceBuffer));
        }

        Context.ApplicationInstance.CompleteRequest();
    }
</script>
