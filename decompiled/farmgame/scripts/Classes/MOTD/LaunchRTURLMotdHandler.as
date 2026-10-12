package Classes.MOTD
{
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class LaunchRTURLMotdHandler extends CustomWindowMOTDHandler
   {
      
      protected var m_url:String = null;
      
      public function LaunchRTURLMotdHandler(currentMOTD:Object)
      {
         super(currentMOTD);
         if(m_windowParams.hasOwnProperty("URL"))
         {
            if(Global.flashHotParams.hasOwnProperty(m_windowParams["URL"]))
            {
               this.m_url = Global.flashHotParams[m_windowParams["URL"]].toString();
               this.m_url = this.m_url.split("/amp").join("&");
            }
         }
      }
      
      override protected function acceptMOTD() : void
      {
         if(this.m_url)
         {
            navigateToURL(new URLRequest(this.m_url),"_blank");
         }
         super.acceptMOTD();
      }
   }
}

