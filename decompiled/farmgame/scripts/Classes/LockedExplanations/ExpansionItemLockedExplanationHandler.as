package Classes.LockedExplanations
{
   import Display.MOTD;
   import Display.UI;
   
   public class ExpansionItemLockedExplanationHandler extends LockedExplanationHandler
   {
      
      public function ExpansionItemLockedExplanationHandler()
      {
         super();
      }
      
      override public function execute(customActionParams:Object = null) : void
      {
         if(customActionParams.worldType)
         {
            UI.closeMarketDialog();
            if(Global.worldManager.hasUnlockedWorld(customActionParams.worldType))
            {
               Global.worldManager.showTravelConfirmation(customActionParams.worldType);
            }
            else
            {
               MOTD.displayMOTD(customActionParams,false,null,null,false);
            }
         }
      }
   }
}

