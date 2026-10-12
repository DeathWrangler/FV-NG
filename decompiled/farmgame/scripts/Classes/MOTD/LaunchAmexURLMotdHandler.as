package Classes.MOTD
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FeatureOptionsManager;
   
   public class LaunchAmexURLMotdHandler extends LaunchURLMotdHandler
   {
      
      public function LaunchAmexURLMotdHandler(currentMOTD:Object)
      {
         super(currentMOTD);
         if(m_url)
         {
            m_url = m_url.split("fbiuidHash").join(Global.player.thirdPartyID);
         }
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         var amexFeatureOption:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.FEATURE_AMEX_TREE,"tree_data");
         if(amexFeatureOption == null)
         {
            UI.displayMessage(ZLocUtils.t_pk("Dialogs","AmexPlacementReminder"),0,null,"AmexMOTDReminder",true);
         }
      }
   }
}

