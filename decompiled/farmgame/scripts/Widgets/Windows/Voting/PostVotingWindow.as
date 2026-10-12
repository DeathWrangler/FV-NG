package Widgets.Windows.Voting
{
   import Classes.Constants.Experiments;
   import Classes.FeatureComponents.VotingComponent;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.OffboardingManager;
   import Managers.VotingDataManager;
   import Transactions.TGenericTransaction;
   import Transactions.TransactionWithCallBack;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.PostVotingSlotFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class PostVotingWindow extends FarmWindow
   {
      
      protected var m_askButton:FarmAnimatedButton = null;
      
      private var m_featureName:String;
      
      private var m_votingComponent:VotingComponent;
      
      private var m_votingDataManager:VotingDataManager;
      
      private var m_dialog:PostVotingSlotFrame = null;
      
      private var m_ReplayCallBack:Function = null;
      
      private const SERVICE_CLASS:String = "VotingService";
      
      private var m_TabIndex:int = 0;
      
      private var m_tab1:FarmTabButton;
      
      private var m_tab2:FarmTabButton;
      
      public function PostVotingWindow(votingComponent:VotingComponent, featureName:String, dialogAssetUrl:String, showWhatIsThisOnLoad:Boolean = false, showCrewProgressFeed:Boolean = false)
      {
         super(dialogAssetUrl);
         this.m_featureName = featureName;
         this.m_votingComponent = votingComponent;
         this.m_votingDataManager = VotingDataManager.getInstance();
         this.m_TabIndex = VotingDataManager.m_selectedTabIndex;
      }
      
      override public function close() : void
      {
         super.close();
      }
      
      override protected function postLoadComplete() : void
      {
         var titlePK:String = VotingComponent.getLocalizedKey(this.m_featureName,"Title");
         var titleTextField:ZwTextField = addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.tk_pk_asTitle(titlePK))) as ZwTextField;
         this.m_dialog = new PostVotingSlotFrame(m_window.slotFrame_mc,this,this.m_featureName,this.m_TabIndex);
         this.m_dialog.setItemData();
         addWidget(this.m_dialog);
         if(m_window.hasOwnProperty("timer_tf") && m_window.timer_tf != null)
         {
            addWidget(new ZwTextField(m_window.timer_tf,"Ask every 9 Hours!"));
         }
         if(m_window.hasOwnProperty("description_tf") && m_window.description_tf != null)
         {
            addWidget(new ZwTextField(m_window.description_tf,ZLocUtils.t("Dialogs","PostVotingWindowsubTitle")));
         }
         if(this.m_votingDataManager.isFeatureOffboarded(this.m_featureName))
         {
            addWidget(new FarmAnimatedTextButton(m_window.replay_bt,"Store!",this.popReplacementConfirmationDialog));
            if(m_window.hasOwnProperty("replay_tf") && m_window.replay_tf != null)
            {
               addWidget(new ZwTextField(m_window.replay_tf,"The event has ended, but the building is yours to keep! Click below!"));
            }
         }
         else
         {
            addWidget(new FarmAnimatedTextButton(m_window.replay_bt,"Replay",this.replayButtonCallback,true));
            if(m_window.hasOwnProperty("replay_tf") && m_window.replay_tf != null)
            {
               addWidget(new ZwTextField(m_window.replay_tf,ZLocUtils.t("Dialogs","PostVotingWindowReplayMessage")));
            }
         }
         this.m_tab1 = new FarmTabButton(m_window.tab_bt_0,ZLocUtils.t("Dialogs",this.m_featureName + VotingDataManager.PERSONALITY_ONE_TEXT) + " Collection",this.TabOneSelected);
         this.m_tab2 = new FarmTabButton(m_window.tab_bt_1,ZLocUtils.t("Dialogs",this.m_featureName + VotingDataManager.PERSONALITY_TWO_TEXT) + " Collection",this.TabTwoSelected);
         addWidget(this.m_tab1);
         addWidget(this.m_tab2);
         if(0 == VotingDataManager.m_selectedTabIndex)
         {
            this.m_tab1.setToggleState(ZwToggleState.SELECTED);
            this.m_tab2.setToggleState(ZwToggleState.DESELECTED);
         }
         else
         {
            this.m_tab2.setToggleState(ZwToggleState.SELECTED);
            this.m_tab1.setToggleState(ZwToggleState.DESELECTED);
         }
      }
      
      public function TabOneSelected(event:Event) : void
      {
         if(this.m_TabIndex != 0)
         {
            this.m_TabIndex = 0;
            VotingDataManager.m_selectedTabIndex = 0;
            this.m_dialog.setItemData();
            this.m_tab1.setToggleState(ZwToggleState.SELECTED);
            this.m_tab2.setToggleState(ZwToggleState.DESELECTED);
         }
      }
      
      public function TabTwoSelected(event:Event) : void
      {
         if(this.m_TabIndex != 1)
         {
            this.m_TabIndex = 1;
            VotingDataManager.m_selectedTabIndex = 1;
            this.m_dialog.setItemData();
            this.m_tab2.setToggleState(ZwToggleState.SELECTED);
            this.m_tab1.setToggleState(ZwToggleState.DESELECTED);
         }
      }
      
      override public function refreshWindow() : void
      {
         this.refreshUI();
      }
      
      private function pause() : void
      {
         if(m_window)
         {
            tintWindow();
            enableInput = false;
         }
      }
      
      private function unpause() : void
      {
         if(m_window)
         {
            untintWindow();
            enableInput = true;
         }
      }
      
      private function replayButtonCallback(event:MouseEvent) : void
      {
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SMART_NAUGHTY_NICE) > 0)
         {
            this.m_votingComponent.gotoNextStage();
         }
         else
         {
            TransactionManager.addTransaction(new TransactionWithCallBack("VotingService.onGoToNextStage",null,this.m_featureName),true);
         }
         FarmStatsManager.count(VotingComponent.FEATURE_COUNTER,this.m_featureName,"replay","click");
         VotingDataManager.getInstance().getDataObject(this.m_featureName).reset();
         var voteResults:Array = VotingDataManager.getInstance().getDataObject(this.m_featureName).voteResults;
         var data:Array = new Array();
         FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,FeatureOptionsManager.POST_VOTING_STATE,data);
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,"resetPostVotingData",null,[this.m_featureName]),true);
         Global.player.setFeatureLastShown(this.m_featureName,0,false);
         this.m_votingComponent.stage = 0;
         this.m_votingComponent.replay();
      }
      
      public function refreshUI() : void
      {
         this.unpause();
         this.m_dialog.setItemData();
      }
      
      public function popReplacementConfirmationDialog(result:Object = null) : void
      {
         var stringPackage:String = VotingComponent.getLocalizedKey(this.m_featureName,"OffboardDescription");
         var popup:GenericPopup = new GenericPopup(ZLocUtils.t_pk(stringPackage,null,{"basketName":ZLocUtils.tk_pk_asTitle("Items:" + this.m_featureName + "_friendlyName")}),GenericPopup.TYPE_ACCEPTCANCEL,this.offboardBuilding);
         popup.setAcceptTextName("VotingOffboardAccept");
         popup.setCancelTextName("VotingOffboardPostpone");
         UI.displayPopup(popup,false);
         if(Global.player.getSeenFlag(this.m_featureName + "ReplacementDialogSeen"))
         {
            FarmStatsManager.count(this.m_featureName,"offboarding","option","view");
         }
      }
      
      protected function offboardBuilding(event:GenericPopupEvent) : void
      {
         var canOffboard:Boolean = false;
         var option:String = "option";
         if(!Global.player.getSeenFlag(this.m_featureName + "ReplacementDialogSeen"))
         {
            option = "initial_option";
         }
         if(Boolean(event) && event.button == GenericPopup.ACCEPT)
         {
            canOffboard = Boolean(this.m_votingComponent) && Boolean(this.m_votingComponent.context);
            if(canOffboard)
            {
               FarmStatsManager.count(this.m_featureName,"offboarding",option,"make_storable");
               OffboardingManager.handleOffBoarding(this.m_votingComponent.context,false,true);
               this.m_votingComponent.closeVotingwindow();
            }
         }
         else
         {
            FarmStatsManager.count(this.m_featureName,"offboarding",option,"keep_basket");
         }
         Global.player.setSeenFlag(this.m_featureName + "ReplacementDialogSeen");
      }
   }
}

