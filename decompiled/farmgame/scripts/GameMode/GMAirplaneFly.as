package GameMode
{
   import AvatarMode.AMAirplane;
   import Classes.Airplane;
   import Classes.Avatar.FarmAvatar;
   import Classes.instagrow.InstagrowUtils;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.UI;
   import Events.ImpulseBuyEvent;
   import Managers.FarmStatsManager;
   import Managers.InstagrowHelper;
   
   public class GMAirplaneFly extends GMDefault
   {
      
      private var m_airplane:Airplane;
      
      private var m_hasBeenActivated:Boolean;
      
      private var m_instagrowHelper:InstagrowHelper;
      
      private var m_prompt:GenericDialog;
      
      public function GMAirplaneFly(airplane:Airplane = null)
      {
         var airplaneName:String = null;
         var planes:Array = null;
         super();
         if(airplane == null)
         {
            airplaneName = Global.worldSettingsManager.getWorldSpecificPlaneItemName(Global.worldManager.currentWorldType,null);
            if(airplaneName != null)
            {
               this.m_airplane = new Airplane(airplaneName,true);
               this.m_airplane.setOuter(Global.world);
            }
            else
            {
               planes = Global.world.getObjectsByClass(Airplane);
               if(planes.length > 0)
               {
                  airplane = planes[0];
               }
            }
         }
         this.m_airplane = airplane;
         this.m_hasBeenActivated = false;
      }
      
      override public function enableMode() : void
      {
         var hasResourcesToGrow:Boolean = false;
         var numFreeFlights:int = 0;
         var message:String = null;
         var acceptText:String = null;
         if(!this.m_hasBeenActivated)
         {
            super.enableMode();
            this.m_hasBeenActivated = true;
            this.m_instagrowHelper = new InstagrowHelper();
            hasResourcesToGrow = this.m_instagrowHelper.hasResourcesToActOn();
            numFreeFlights = this.getNumberOfFreeFlights();
            if(numFreeFlights > 0)
            {
               message = "";
               if(!hasResourcesToGrow)
               {
                  message = ZLocUtils.t("Dialogs","InstantGrowConsumable_NoCropsBody");
                  UI.showMessage(message,UI.BUTTON_LAYOUT_OK,null,null,false);
                  disableMode();
                  Global.world.addGameMode(new GMDefault());
               }
               else
               {
                  message = ZLocUtils.t("Dialogs","InstantGrow_ReadyToFlyFree",{
                     "quantity":numFreeFlights,
                     "application":ZLocUtils.tk("Dialogs","InstantGrow_applications_word","",numFreeFlights)
                  });
                  acceptText = ZLocUtils.t("Dialogs","InstantGrow_AcceptGrowCrops");
                  disableMode();
                  this.m_hasBeenActivated = false;
                  Global.world.addGameMode(new GMDefault());
                  this.m_prompt = UI.showMessage(message,UI.BUTTON_LAYOUT_ACCEPT_CANCEL,null,null,false,this.onReadyToFlyFreeDialogClose,null,false,acceptText);
               }
            }
            else if(!hasResourcesToGrow)
            {
               UI.showMessage(ZLocUtils.t("Dialogs","InstantGrowConsumable_NoCropsBody"),UI.BUTTON_LAYOUT_OK,null,null,false);
               disableMode();
               Global.world.addGameMode(new GMDefault());
            }
            else
            {
               InstagrowUtils.tryShowInstagrowWindow(InstagrowUtils.SOURCE_CONTEXT_MENU,this.m_airplane,this.m_instagrowHelper);
            }
         }
         else
         {
            disableMode();
            Global.world.addGameMode(new GMDefault());
         }
      }
      
      override public function canAdd() : Boolean
      {
         var result:Boolean = false;
         if(Global.world.isGameModeActive(GMAirplaneFly) == false)
         {
            result = true;
         }
         return result;
      }
      
      private function getNumberOfFreeFlights() : int
      {
         var result:int = 0;
         if(Global.world.getObjectsByClass(Airplane).length > 0 && !Global.player.getSeenFlag(Airplane.FIRST_AIRPLANE_FLY_FLAG) && !Global.player.getSeenSessionFlag(Airplane.FIRST_AIRPLANE_FLY_FLAG))
         {
            result = 1;
         }
         return int(result + Global.player.getFarmServiceCredits(Airplane.SERVICE_NAME));
      }
      
      private function doGrow() : void
      {
         var avatar:FarmAvatar = Global.selectedAvatar;
         avatar.getStateMachine().addState(new AMAirplane(avatar,this.m_instagrowHelper,this.m_airplane as Airplane),true);
      }
      
      private function onReadyToFlyFreeDialogClose(isAccept:Boolean) : void
      {
         var actionString:String = null;
         if(isAccept)
         {
            super.enableMode();
            this.m_hasBeenActivated = true;
            if(Global.world.getObjectsByClass(Airplane).length > 0 && !Global.player.getSeenFlag(Airplane.FIRST_AIRPLANE_FLY_FLAG) && !Global.player.getSeenSessionFlag(Airplane.FIRST_AIRPLANE_FLY_FLAG))
            {
               Global.player.setSeenSessionFlag(Airplane.FIRST_AIRPLANE_FLY_FLAG);
            }
            else
            {
               Global.player.useFarmServiceCredit(Airplane.SERVICE_NAME);
            }
            this.doGrow();
            actionString = "Accept";
         }
         else
         {
            actionString = "Cancel";
         }
         FarmStatsManager.count(InstagrowUtils.INSTA_GROW_COUNTER,"Free_flight",actionString);
         if(this.m_prompt)
         {
            this.m_prompt.destroy();
            this.m_prompt = null;
         }
      }
      
      private function onGetMoreFarmCashAccept(event:ImpulseBuyEvent) : void
      {
         event.target.removeEventListener(ImpulseBuyEvent.ACCEPT,this.onGetMoreFarmCashAccept);
         event.target.removeEventListener(ImpulseBuyEvent.CANCEL,this.onGetMoreFarmCashCancel);
         FarmStatsManager.count(InstagrowUtils.INSTA_GROW_COUNTER,"Need_more_FC","Accept");
      }
      
      private function onGetMoreFarmCashCancel(event:ImpulseBuyEvent) : void
      {
         event.target.removeEventListener(ImpulseBuyEvent.ACCEPT,this.onGetMoreFarmCashAccept);
         event.target.removeEventListener(ImpulseBuyEvent.CANCEL,this.onGetMoreFarmCashCancel);
         FarmStatsManager.count(InstagrowUtils.INSTA_GROW_COUNTER,"Need_more_FC","Cancel");
      }
   }
}

