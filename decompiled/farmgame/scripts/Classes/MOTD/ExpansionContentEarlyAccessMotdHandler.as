package Classes.MOTD
{
   import Classes.ZItem.ContentAccessSettings;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Windows.Expansion.ExpansionOnboardingWindow;
   
   public class ExpansionContentEarlyAccessMotdHandler extends RepeatableMOTDHandler
   {
      
      private var m_contentAccessType:String = null;
      
      private var m_assetPath:String = null;
      
      public function ExpansionContentEarlyAccessMotdHandler(currentMOTD:Object)
      {
         super(currentMOTD);
         if(m_currentMOTD.hasOwnProperty("contentAccess") && m_currentMOTD["contentAccess"] != null)
         {
            this.m_contentAccessType = m_currentMOTD["contentAccess"];
            if(m_currentMOTD.hasOwnProperty("assetPath") && m_currentMOTD["assetPath"] != null)
            {
               this.m_assetPath = m_currentMOTD["assetPath"];
               return;
            }
            throw new Error("Invalid content access MOTD, could not find content access type definition for world: " + m_currentMOTD.motdSeenFlag);
         }
         throw new Error("Invalid content access MOTD, could not find content access type definition for world: " + m_currentMOTD.motdSeenFlag);
      }
      
      private function get assetPath() : String
      {
         return this.m_assetPath;
      }
      
      private function get brochureButtonZLocKey() : String
      {
         return "Buy and Go";
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         this.unlockEarlyExpansionContent();
      }
      
      override public function execute() : void
      {
         UI.displayPopup(new ExpansionOnboardingWindow(this.assetPath,ZLocUtils.t("Dialogs",this.brochureButtonZLocKey),this.acceptMOTD,this.closeMOTD,null,m_currentMOTD["worldType"]),m_addToQueue);
         super.execute();
      }
      
      private function unlockEarlyExpansionContent() : void
      {
         var contentAccessSettings:ContentAccessSettings = null;
         if(this.m_contentAccessType != null)
         {
            Global.player.purchaseContentAccess(this.m_contentAccessType);
            contentAccessSettings = Global.farmGameSettingsManager.getContentAccessSettings(this.m_contentAccessType);
            if(contentAccessSettings)
            {
               contentAccessSettings.hideHudIcons();
            }
         }
      }
   }
}

