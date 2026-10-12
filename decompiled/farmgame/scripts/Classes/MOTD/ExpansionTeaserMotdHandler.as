package Classes.MOTD
{
   import Classes.ZItem.ExpansionData;
   import Display.UI;
   import Widgets.Windows.Expansion.ExpansionOnboardingWindow;
   
   public class ExpansionTeaserMotdHandler extends MOTDHandler
   {
      
      protected var m_expansionData:ExpansionData;
      
      public function ExpansionTeaserMotdHandler(currentMOTD:Object)
      {
         super(currentMOTD);
         var worldId:String = m_currentMOTD["worldType"];
         if(worldId)
         {
            this.m_expansionData = Global.farmGameSettingsManager.getExpansionData(worldId);
            if(this.m_expansionData == null)
            {
               throw new Error("Invalid expansion MOTD, could not find expansion definition for world: " + worldId);
            }
            return;
         }
         throw new Error("Invalid expansion MOTD, null worldId [seenFlag=" + m_currentMOTD["motdSeenFlag"] + "]");
      }
      
      override public function execute() : void
      {
         UI.displayPopup(new ExpansionOnboardingWindow(this.m_expansionData.motdAssets["teaser"][ExpansionData.KEY_ASSET],"",null,acceptMOTD,null,m_currentMOTD["worldType"]));
         super.execute();
      }
   }
}

