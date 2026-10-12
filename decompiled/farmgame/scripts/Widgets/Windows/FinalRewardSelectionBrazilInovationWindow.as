package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureOptionsManager;
   import Managers.OrderBoard.DreamWorldInnovationManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FinalRewardSelectionBrazilInovationWindow extends FarmWindow
   {
      
      private static const SERVICE_NAME:String = "DreamWorldInnovationService";
      
      private static const SERVICE_METHOD:String = "onChosingFinalRewrdColorOption";
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const SLOT_MC:String = "slots_mc";
      
      private const CONTINUE_BT:String = "close_bt";
      
      private const SLOT_0_MC:String = "slot_0_mc";
      
      private const ICON_MC:String = "icon_mc";
      
      private const GENERIC_TF:String = "generic_tf";
      
      private const SELECT0_BT:String = "select0_bt";
      
      private const TAKEN_MC0:String = "taken0_mc";
      
      private const SLOT_1_MC:String = "slot_1_mc";
      
      private const SELECT1_BT:String = "select1_bt";
      
      private const TAKEN_MC1:String = "taken1_mc";
      
      private const SLOT_2_MC:String = "slot_2_mc";
      
      private const SELECT2_BT:String = "select2_bt";
      
      private const TAKEN_MC2:String = "taken2_mc";
      
      private const SLOT_3_MC:String = "slot_3_mc";
      
      private const SELECT3_BT:String = "select3_bt";
      
      private const TAKEN_MC3:String = "taken3_mc";
      
      private var m_position:int = 0;
      
      private var m_featureName:String = null;
      
      protected var m_iconPreview1:FarmIcon;
      
      protected var m_iconPreview2:FarmIcon;
      
      protected var m_iconPreview3:FarmIcon;
      
      protected var m_iconPreview4:FarmIcon;
      
      private var m_choice1:ZwBaseWidget;
      
      private var m_choice1Check:ZwBaseWidget;
      
      private var m_choice2:ZwBaseWidget;
      
      private var m_choice2Check:ZwBaseWidget;
      
      private var m_choice3:ZwBaseWidget;
      
      private var m_choice3Check:ZwBaseWidget;
      
      private var m_choice4:ZwBaseWidget;
      
      private var m_choice4Check:ZwBaseWidget;
      
      private var m_differentColorItemList:Array = new Array();
      
      private var m_selectedBonus:String;
      
      private var m_position_chosen:int;
      
      protected var m_continueButton:FarmAnimatedTextButton;
      
      private var m_slot_mc:MovieClip;
      
      private var m_slot_0_mc:MovieClip;
      
      private var m_slot_1_mc:MovieClip;
      
      private var m_slot_2_mc:MovieClip;
      
      private var m_slot_3_mc:MovieClip;
      
      private var m_bodyText:ZwTextField;
      
      private var m_feedConfig:Object = {};
      
      private var m_rewardWindow:GenericSingleRewardPopup;
      
      private var m_rewardName:String;
      
      private var m_resultObject:Object;
      
      private var m_isActive:Boolean = false;
      
      public function FinalRewardSelectionBrazilInovationWindow(dialogAsset:String, featureName:String, position:int)
      {
         super(dialogAsset);
         this.m_featureName = featureName;
         this.m_position = position;
      }
      
      override protected function postLoadComplete() : void
      {
         var item0:FarmItem = null;
         var itemName0:String = null;
         var item1:FarmItem = null;
         var itemName1:String = null;
         var secondSelectBtn:FarmAnimatedTextButton = null;
         var item2:FarmItem = null;
         var itemName2:String = null;
         var thirdSelectBtn:FarmAnimatedTextButton = null;
         var item3:FarmItem = null;
         var itemName3:String = null;
         var fourthSelectBtn:FarmAnimatedTextButton = null;
         super.postLoadComplete();
         this.m_differentColorItemList = DreamWorldInnovationManager.getInstance(this.m_featureName).getFinalReward();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_title_txt")));
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            addWidget(this.m_bodyText = new ZwTextField(m_window[this.BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_body_txt")));
         }
         if(m_window.hasOwnProperty(this.SLOT_MC))
         {
            this.m_slot_mc = m_window.slots_mc as MovieClip;
            if(this.m_slot_mc.hasOwnProperty(this.SLOT_0_MC))
            {
               this.m_slot_0_mc = this.m_slot_mc.slot_0_mc as MovieClip;
               item0 = Global.farmGameSettingsManager.getFarmItemByName(this.m_differentColorItemList[1]);
               itemName0 = ZLocUtils.tk_pk_asTitle(item0.friendlyName);
               if(this.m_iconPreview1)
               {
                  removeWidget(this.m_iconPreview1);
               }
               m_window.slots_mc.visible = true;
               if(this.m_slot_0_mc.hasOwnProperty("select0_bt") && this.m_position <= 1)
               {
                  addWidget(new FarmAnimatedTextButton(this.m_slot_0_mc.select0_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_select_btn_txt"),this.selectedBonus1));
                  if(this.m_slot_0_mc.hasOwnProperty(this.TAKEN_MC0))
                  {
                     this.m_slot_0_mc.taken0_mc.visible = false;
                  }
               }
               else
               {
                  this.m_slot_0_mc.taken0_mc.visible = true;
                  this.m_slot_0_mc.select0_bt.visible = false;
               }
            }
            if(this.m_slot_mc.hasOwnProperty(this.SLOT_1_MC))
            {
               this.m_slot_1_mc = this.m_slot_mc.slot_1_mc as MovieClip;
               item1 = Global.farmGameSettingsManager.getFarmItemByName(this.m_differentColorItemList[2]);
               itemName1 = ZLocUtils.tk_pk_asTitle(item1.friendlyName);
               m_window.slots_mc.visible = true;
               if(this.m_slot_1_mc.hasOwnProperty("select1_bt") && this.m_position <= 2)
               {
                  addWidget(new FarmAnimatedTextButton(m_window.slots_mc.slot_1_mc.select1_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_select_btn_txt"),this.selectedBonus2));
                  if(this.m_slot_1_mc.hasOwnProperty(this.TAKEN_MC1))
                  {
                     this.m_slot_1_mc.taken1_mc.visible = false;
                  }
               }
               else
               {
                  this.m_slot_1_mc.taken1_mc.visible = true;
                  this.m_slot_1_mc.select1_bt.visible = false;
               }
            }
            if(this.m_slot_mc.hasOwnProperty(this.SLOT_2_MC))
            {
               this.m_slot_2_mc = this.m_slot_mc.slot_2_mc as MovieClip;
               item2 = Global.farmGameSettingsManager.getFarmItemByName(this.m_differentColorItemList[2]);
               itemName2 = ZLocUtils.tk_pk_asTitle(item2.friendlyName);
               if(this.m_iconPreview3)
               {
                  removeWidget(this.m_iconPreview3);
               }
               m_window.slots_mc.visible = true;
               if(this.m_slot_2_mc.hasOwnProperty("select2_bt") && this.m_position <= 3)
               {
                  addWidget(new FarmAnimatedTextButton(this.m_slot_2_mc.select2_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_select_btn_txt"),this.selectedBonus3));
                  if(this.m_slot_2_mc.hasOwnProperty(this.TAKEN_MC2))
                  {
                     this.m_slot_2_mc.taken2_mc.visible = false;
                  }
               }
               else
               {
                  this.m_slot_2_mc.taken2_mc.visible = true;
                  this.m_slot_2_mc.select2_bt.visible = false;
               }
            }
            if(this.m_slot_mc.hasOwnProperty(this.SLOT_3_MC))
            {
               this.m_slot_3_mc = this.m_slot_mc.slot_3_mc as MovieClip;
               item3 = Global.farmGameSettingsManager.getFarmItemByName(this.m_differentColorItemList[4]);
               itemName3 = ZLocUtils.tk_pk_asTitle(item3.friendlyName);
               m_window.slots_mc.visible = true;
               if(this.m_slot_3_mc.hasOwnProperty("select3_bt") && this.m_position <= 4)
               {
                  addWidget(new FarmAnimatedTextButton(this.m_slot_3_mc.select3_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_select_btn_txt"),this.selectedBonus4));
                  if(this.m_slot_3_mc.hasOwnProperty(this.TAKEN_MC3))
                  {
                     this.m_slot_3_mc.taken3_mc.visible = false;
                  }
               }
               else
               {
                  this.m_slot_3_mc.taken3_mc.visible = true;
                  this.m_slot_3_mc.select3_bt.visible = false;
               }
            }
         }
      }
      
      private function setBodyText() : void
      {
         var positionText:String = null;
         switch(this.m_position)
         {
            case 1:
               positionText = "1st";
               break;
            case 2:
               positionText = "2nd";
               break;
            case 3:
               positionText = "3rd";
               break;
            case 4:
               positionText = "4th";
               break;
            default:
               positionText = "";
         }
         this.m_bodyText.text = "Great Work! Now apply the final touches to the temple to finish restoring it!";
      }
      
      private function selectedBonus1(event:Event) : void
      {
         this.m_selectedBonus = this.m_differentColorItemList[1];
         this.m_position_chosen = 1;
         this.onChoseColoroption();
      }
      
      private function selectedBonus2(event:Event) : void
      {
         this.m_selectedBonus = this.m_differentColorItemList[2];
         this.m_position_chosen = 2;
         this.onChoseColoroption();
      }
      
      private function selectedBonus3(event:Event) : void
      {
         this.m_selectedBonus = this.m_differentColorItemList[3];
         this.m_position_chosen = 3;
         this.onChoseColoroption();
      }
      
      private function selectedBonus4(event:Event) : void
      {
         this.m_selectedBonus = this.m_differentColorItemList[4];
         this.m_position_chosen = 4;
         this.onChoseColoroption();
      }
      
      private function onChoseColoroption() : void
      {
         if(this.m_position_chosen)
         {
            DreamWorldInnovationManager.getInstance(this.m_featureName).replceIntermediateRewardWithFinalReward(this.m_position_chosen,this.m_position.toString());
            FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,DreamWorldInnovationManager.KEY_SAVED_FINAL_REWARD_RECEIVED,this.m_position);
            close();
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,SERVICE_METHOD,null,new Array(this.m_featureName,this.m_position_chosen)));
            DreamWorldInnovationManager.getInstance(this.m_featureName).showFinalRewardPopup(this.m_selectedBonus,this.m_position);
         }
      }
   }
}

