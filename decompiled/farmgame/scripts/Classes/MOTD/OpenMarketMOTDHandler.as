package Classes.MOTD
{
   import Display.UI;
   
   public class OpenMarketMOTDHandler extends CustomWindowActionMOTDHandler
   {
      
      public function OpenMarketMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      public function openLimitedOrSpecialTab(actionParams:Object) : void
      {
         UI.displayMarketDialog("MOTD","special");
      }
      
      public function openMarketTab(actionParams:Object) : void
      {
         var tab:String = "";
         if(actionParams.hasOwnProperty("tab") && actionParams["tab"] != null)
         {
            tab = actionParams["tab"];
         }
         var miniSlotsTab:String = null;
         if(actionParams.hasOwnProperty("miniSlotsTab") && actionParams["miniSlotsTab"] != null)
         {
            miniSlotsTab = actionParams["miniSlotsTab"];
         }
         UI.displayMarketDialog("MOTD",tab,null,"all",null,null,null,null,-1,null,miniSlotsTab);
      }
   }
}

