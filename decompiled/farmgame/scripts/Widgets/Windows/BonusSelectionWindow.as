package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.ChoiceDrivenManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.events.Event;
   
   public class BonusSelectionWindow extends FarmWindow
   {
      
      protected var m_featureName:String;
      
      private const TITLE_TF:String = "title_tf";
      
      private const DESCRIPTION_TF:String = "description_tf";
      
      private const ICON1_MC:String = "icon1_mc";
      
      private const CHOICE1_BT:String = "choice1_bt";
      
      private const CHECK1_MC:String = "check1_mc";
      
      private const CHECKBACK1_MC:String = "checkBack1_mc";
      
      private const GENERIC1_TF:String = "generic1_tf";
      
      private const ICON2_MC:String = "icon2_mc";
      
      private const CHOICE2_BT:String = "choice2_bt";
      
      private const CHECK2_MC:String = "check2_mc";
      
      private const CHECKBACK2_MC:String = "checkBack2_mc";
      
      private const GENERIC2_TF:String = "generic2_tf";
      
      private const CONTINUE_BT:String = "continue_bt";
      
      private const TEXT_TITLE:String = "_bonus_title";
      
      private const TEXT_DESC:String = "_bonus_description";
      
      private const TEXT_BONUS_CHOICE:String = "_bonus_Choice1Text";
      
      private const TEXT_BONUS_NOT_SELECTED:String = "_bonus_not_selected";
      
      protected var m_iconPreview:FarmIcon;
      
      private var m_choice1:ZwBaseWidget;
      
      private var m_choice1Check:ZwBaseWidget;
      
      private var m_choice2:ZwBaseWidget;
      
      private var m_choice2Check:ZwBaseWidget;
      
      protected var m_continueButton:FarmAnimatedTextButton;
      
      private var m_bonusItemList:Array;
      
      private var m_selectedBonus:String = null;
      
      public function BonusSelectionWindow(dialogPath:String, bonusItemList:Array, featureName:String)
      {
         this.m_bonusItemList = bonusItemList;
         this.m_featureName = featureName;
         super(dialogPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var item:FarmItem = null;
         var itemName:String = null;
         var infoTooltip:FarmTextTooltip = null;
         var choice1:ZwBaseWidget = null;
         var choice2:ZwBaseWidget = null;
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_TITLE)));
         }
         if(m_window.hasOwnProperty(this.DESCRIPTION_TF))
         {
            addWidget(new ZwTextField(m_window[this.DESCRIPTION_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_DESC)));
         }
         if(m_window.hasOwnProperty(this.ICON1_MC))
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_bonusItemList[0].name);
            itemName = ZLocUtils.tk_pk_asTitle(item.friendlyName);
            infoTooltip = new FarmTextTooltip(itemName);
            this.m_iconPreview = getWidget(m_window[this.ICON1_MC]) as FarmIcon;
            if(this.m_iconPreview)
            {
               removeWidget(this.m_iconPreview);
            }
            this.m_iconPreview = new FarmIcon(m_window[this.ICON1_MC],item.getImageByName("feed"));
            this.m_iconPreview.setIconSize(150,150);
            addWidget(this.m_iconPreview,true);
            this.m_iconPreview.attachTooltip(infoTooltip);
         }
         if(m_window.hasOwnProperty(this.ICON2_MC))
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_bonusItemList[1].name);
            itemName = ZLocUtils.tk_pk_asTitle(item.friendlyName);
            infoTooltip = new FarmTextTooltip(itemName);
            this.m_iconPreview = getWidget(m_window[this.ICON2_MC]) as FarmIcon;
            if(this.m_iconPreview)
            {
               removeWidget(this.m_iconPreview);
            }
            this.m_iconPreview = new FarmIcon(m_window[this.ICON2_MC],item.getImageByName("feed"));
            this.m_iconPreview.setIconSize(150,150);
            addWidget(this.m_iconPreview,true);
            this.m_iconPreview.attachTooltip(infoTooltip);
         }
         if(m_window.hasOwnProperty(this.CHOICE1_BT))
         {
            choice1 = addWidget(new FarmButton(m_window[this.CHOICE1_BT],this.selectedBonus1),true);
            if(choice1 != null && Boolean(m_window[this.CHOICE1_BT].hasOwnProperty(this.CHOICE1_BT)))
            {
               this.m_choice1 = addWidget(new ZwBaseWidget(m_window[this.CHOICE1_BT][this.CHECKBACK1_MC]),true);
            }
            if(choice1 != null && Boolean(m_window[this.CHOICE1_BT].hasOwnProperty(this.CHECK1_MC)))
            {
               this.m_choice1Check = addWidget(new ZwBaseWidget(m_window[this.CHOICE1_BT][this.CHECK1_MC]),false);
            }
            if(choice1 != null && Boolean(m_window[this.CHOICE1_BT].hasOwnProperty(this.GENERIC1_TF)))
            {
               addWidget(new FarmTextField(m_window[this.CHOICE1_BT][this.GENERIC1_TF],ZLocUtils.t("Dialogs",this.m_featureName + this.TEXT_BONUS_CHOICE)),true);
            }
         }
         if(m_window.hasOwnProperty(this.CHOICE2_BT))
         {
            choice2 = addWidget(new FarmButton(m_window[this.CHOICE2_BT],this.selectedBonus2),true);
            if(choice2 != null && Boolean(m_window[this.CHOICE2_BT].hasOwnProperty(this.CHOICE2_BT)))
            {
               this.m_choice2 = addWidget(new ZwBaseWidget(m_window[this.CHOICE2_BT][this.CHECKBACK2_MC]),true);
            }
            if(choice2 != null && Boolean(m_window[this.CHOICE2_BT].hasOwnProperty(this.CHECK2_MC)))
            {
               this.m_choice2Check = addWidget(new ZwBaseWidget(m_window[this.CHOICE2_BT][this.CHECK2_MC]),false);
            }
            if(choice2 != null && Boolean(m_window[this.CHOICE2_BT].hasOwnProperty(this.GENERIC2_TF)))
            {
               addWidget(new FarmTextField(m_window[this.CHOICE2_BT][this.GENERIC2_TF],ZLocUtils.t("Dialogs",this.m_featureName + this.TEXT_BONUS_CHOICE)),true);
            }
         }
         if(m_window.hasOwnProperty(this.CONTINUE_BT))
         {
            this.m_continueButton = new FarmAnimatedTextButton(m_window[this.CONTINUE_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Continue"),this.saveBonusAndOpenFightUI);
            addWidget(this.m_continueButton);
            FarmGameUtil.disableButtonAndShowTooltip(this.m_continueButton,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BONUS_NOT_SELECTED));
         }
         super.postLoadComplete();
      }
      
      private function selectedBonus1(event:Event) : void
      {
         if(this.m_choice1Check != null && this.m_choice2Check != null)
         {
            this.m_choice1Check.visible = true;
            this.m_choice2Check.visible = false;
            this.m_selectedBonus = this.m_bonusItemList[0].name;
            this.m_continueButton.enabled = true;
            this.m_continueButton.detachTooltip();
         }
      }
      
      private function selectedBonus2(event:Event) : void
      {
         if(this.m_choice1Check != null && this.m_choice2Check != null)
         {
            this.m_choice1Check.visible = false;
            this.m_choice2Check.visible = true;
            this.m_selectedBonus = this.m_bonusItemList[1].name;
            this.m_continueButton.enabled = true;
            this.m_continueButton.detachTooltip();
         }
      }
      
      private function saveBonusAndOpenFightUI(event:Event) : void
      {
         if(Boolean(this.m_selectedBonus) && Boolean(this.m_continueButton))
         {
            this.m_continueButton.enabled = false;
            ChoiceDrivenManager.getInstance(this.m_featureName).chooseBonus(this.m_selectedBonus);
            close();
            ChoiceDrivenManager.getInstance(this.m_featureName).showFightUI();
         }
      }
   }
}

