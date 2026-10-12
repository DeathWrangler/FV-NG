package Init.Worlds
{
   import Display.UI;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Widgets.Windows.Expansion.MeadowsFTUIWindow;
   
   public class MeadowsWorldInit extends HomeWorldInit
   {
      
      public static const ICON_CODE_MEADOW_MINI_MARKET:String = "231";
      
      private static const SEEN_FLAG:String = "meadowsFirstTimeVisit";
      
      public function MeadowsWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(ICON_CODE_MEADOW_MINI_MARKET));
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         Global.hud.rightSideIconQueue.removeIconByCode(ICON_CODE_MEADOW_MINI_MARKET);
         super.onLeaveWorld(destIsVisiting);
      }
      
      override public function setupUI() : void
      {
         super.setupUI();
         if(!Global.player.getSeenFlag(SEEN_FLAG))
         {
            Global.player.setSeenFlag(SEEN_FLAG);
            UI.displayPopup(new MeadowsFTUIWindow(),false);
         }
      }
   }
}

