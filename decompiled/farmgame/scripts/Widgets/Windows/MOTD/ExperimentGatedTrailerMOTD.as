package Widgets.Windows.MOTD
{
   import Classes.Constants.Experiments;
   import Managers.FarmStatsManager;
   
   public class ExperimentGatedTrailerMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      public function ExperimentGatedTrailerMOTD(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_accept_bt)
         {
            if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_TRAILER_MOTD) > 1)
            {
               m_accept_bt.text = "Awesome";
               m_accept_bt.callback = onClose;
               FarmStatsManager.count("MOTD_TRAILER_TEST","click",m_currentMOTD.motdSeenFlag,"without_video");
            }
            else
            {
               FarmStatsManager.count("MOTD_TRAILER_TEST","click",m_currentMOTD.motdSeenFlag,"with_video");
            }
         }
      }
   }
}

