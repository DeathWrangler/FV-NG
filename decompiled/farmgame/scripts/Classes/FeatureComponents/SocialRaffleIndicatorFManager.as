package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.Friend;
   import Classes.SocialRaffle.SocialRaffleDataView;
   import GameMode.GMBuild;
   import Managers.SocialRaffleManager;
   
   public class SocialRaffleIndicatorFManager extends ArrowIndicatorFManager implements IStateIndicatorComponent
   {
      
      public static const STATE_MADE_PROGRESS:String = "made_progress";
      
      public static const STATE_RAFFLE_COMPLETE:String = "raffle_complete";
      
      public function SocialRaffleIndicatorFManager(owner:FeatureBuilding)
      {
         m_owner = owner;
         super(owner);
      }
      
      override public function canDisplay() : Boolean
      {
         return true;
      }
      
      override public function show(state:String = "default") : void
      {
         var indicatorState:String = this.getArrowIndicatorType();
         super.show(indicatorState);
      }
      
      private function getLastHelpFriendPic() : String
      {
         var getLastFriendUidHelp:String = null;
         var friend:Friend = null;
         var iconUrl:String = "";
         var dataView:SocialRaffleDataView = SocialRaffleManager.getInstance().raffleDataView;
         if(dataView != null)
         {
            getLastFriendUidHelp = dataView.getLastFriendUidHelp();
            friend = Global.friendManager.getAppFriendData(getLastFriendUidHelp);
            if(friend)
            {
               iconUrl = friend.picture;
            }
         }
         return iconUrl;
      }
      
      private function getArrowIndicatorType() : String
      {
         var hasSeenArrow:Boolean = false;
         var dataView:SocialRaffleDataView = null;
         var arrowState:Object = null;
         var type:String = "";
         var currentGMs:Array = Global.world.getActiveGameModes();
         m_lookInsideOnClick = false;
         if(!Global.worldManager.isVisiting() || !(currentGMs[0] is GMBuild))
         {
            hasSeenArrow = Global.player.getSeenSessionFlag("clickedRaffleArrow");
            dataView = SocialRaffleManager.getInstance().raffleDataView;
            if(dataView != null)
            {
               if(SocialRaffleManager.getInstance().isRaffleComplete())
               {
                  type = STATE_RAFFLE_COMPLETE;
                  m_lookInsideOnClick = true;
               }
               else if(!hasSeenArrow && dataView.madeProgress)
               {
                  type = STATE_MADE_PROGRESS;
                  arrowState = this.getState(type);
                  arrowState.icon = this.getLastHelpFriendPic();
                  this.setState(type,arrowState);
                  m_lookInsideOnClick = true;
               }
            }
         }
         return type;
      }
      
      override public function onClick() : void
      {
         SocialRaffleManager.getInstance().setMadeProgress();
      }
      
      override public function hide() : void
      {
         super.hide();
      }
   }
}

