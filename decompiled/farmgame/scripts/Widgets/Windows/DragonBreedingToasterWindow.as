package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.DragonBreedingConfigManager;
   import Managers.DragonBreedingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class DragonBreedingToasterWindow extends AutoCloseToasterWindow
   {
      
      private static const ACCEPT_BTN:String = "accept_bt";
      
      private static const ICON_MC:String = "icon_mc";
      
      private static const HATCH_MC:String = "hatch_mc";
      
      private static const DESCRP_TF:String = "description_tf";
      
      private static const TITLE_TF:String = "title_tf";
      
      private static const TEND_MC:String = "tend_mc";
      
      private static const DESCRIPTION_TXT:String = "_descrp";
      
      private static const TITLE_TXT:String = "_title";
      
      private static const BUTTON_TXT:String = "_btnTxt";
      
      private var m_featureName:String;
      
      private var m_titleTxt:ZwTextField;
      
      private var m_descriptionText:ZwTextField;
      
      private var m_acceptBtn:FarmAnimatedTextButton;
      
      private var m_iconMc:MovieClip;
      
      private var m_hatchMc:MovieClip;
      
      private var m_tendMc:MovieClip;
      
      public function DragonBreedingToasterWindow(windowAssetPath:String, featureName:String)
      {
         this.m_featureName = featureName;
         super(windowAssetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(TITLE_TF))
         {
            addWidget(this.m_titleTxt = new ZwTextField(m_window[TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_toaster1_title")),false);
         }
         if(m_window.hasOwnProperty(DESCRP_TF))
         {
            addWidget(this.m_descriptionText = new ZwTextField(m_window[DESCRP_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_toaster1_descrp")),false);
         }
         if(m_window.hasOwnProperty(ACCEPT_BTN))
         {
            this.m_acceptBtn = addWidget(new FarmAnimatedTextButton(m_window[ACCEPT_BTN],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_toaster1_btnTxt"),this.onAcceptButtonClick),false) as FarmAnimatedTextButton;
         }
         if(m_window.hasOwnProperty(HATCH_MC))
         {
            this.m_hatchMc = m_window[HATCH_MC];
            this.m_hatchMc.visible = false;
         }
         if(m_window.hasOwnProperty(TEND_MC))
         {
            this.m_tendMc = m_window[TEND_MC];
            this.m_tendMc.visible = false;
         }
         this.showDialogByWindowType();
      }
      
      private function showDialogByWindowType() : void
      {
         this.m_titleTxt.text = this.setTitleDescriptionBtnText(TITLE_TXT);
         this.m_titleTxt.visible = true;
         this.m_descriptionText.text = this.setTitleDescriptionBtnText(DESCRIPTION_TXT);
         this.m_descriptionText.visible = true;
         this.m_acceptBtn.text = this.setTitleDescriptionBtnText(BUTTON_TXT);
         this.m_acceptBtn.visible = true;
      }
      
      private function setTitleDescriptionBtnText(textType:String) : String
      {
         var msg:String = "";
         var zlocTxt:String = "";
         var femaleDragonName:String = "";
         var maleDragonName:String = "";
         var userName:String = Global.player.firstName;
         if(DragonBreedingManager.getInstance(this.m_featureName).toasterWindowType == DragonBreedingManager.TOASTER_SHOW_EGG_READY)
         {
            if(Boolean(this.m_tendMc) && !this.m_tendMc)
            {
               this.m_tendMc.visible = true;
            }
            zlocTxt = this.m_featureName + "_toaster" + DragonBreedingManager.getInstance(this.m_featureName).toasterWindowType + textType;
            femaleDragonName = this.getBreedCompleteItemName(DragonBreedingConfigManager.GENDER_CODE_FEMALE);
            msg = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,zlocTxt,{
               "user":userName,
               "femaleDragonName":femaleDragonName
            });
         }
         else if(DragonBreedingManager.getInstance(this.m_featureName).toasterWindowType == DragonBreedingManager.TOASTER_SHOW_HATCH_READY)
         {
            if(Boolean(this.m_hatchMc) && !this.m_hatchMc)
            {
               this.m_hatchMc.visible = true;
            }
            zlocTxt = this.m_featureName + "_toaster" + DragonBreedingManager.getInstance(this.m_featureName).toasterWindowType + textType;
            femaleDragonName = this.getHatchReadyItemName(DragonBreedingConfigManager.GENDER_CODE_FEMALE);
            maleDragonName = this.getHatchReadyItemName(DragonBreedingConfigManager.GENDER_CODE_MALE);
            msg = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,zlocTxt,{
               "user":userName,
               "femaleDragonName":femaleDragonName,
               "maleDragonName":maleDragonName
            });
         }
         else if(DragonBreedingManager.getInstance(this.m_featureName).toasterWindowType == DragonBreedingManager.TOASTER_SHOW_VISITING_DRAGON)
         {
            zlocTxt = this.m_featureName + "_toaster" + DragonBreedingManager.getInstance(this.m_featureName).toasterWindowType + textType;
            msg = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,zlocTxt,{
               "user":userName,
               "DragonName":this.visitingDragonItemName(),
               "time":this.visitingDragonTimeRemaining()
            });
            if(!this.m_iconMc)
            {
               this.showVisitingDragonIcon();
            }
         }
         return msg;
      }
      
      private function visitingDragonItemName() : String
      {
         var result:String = "";
         var itemCode:String = this.getVisitingDragonItemCode();
         if(itemCode != "")
         {
            result = (Global.farmGameSettingsManager.getFarmItemByCode(itemCode) as FarmItem).friendlyTitle;
         }
         return result;
      }
      
      private function getVisitingDragonItemCode() : String
      {
         var visitingDragonItemCodeArray:Array = DragonBreedingManager.getInstance(this.m_featureName).getVisitingDragonItemCodeAsArray();
         var itemCode:String = "";
         if(Boolean(visitingDragonItemCodeArray) && visitingDragonItemCodeArray.length > 0)
         {
            itemCode = visitingDragonItemCodeArray[0];
         }
         return itemCode;
      }
      
      private function visitingDragonTimeRemaining() : String
      {
         var result:String = "";
         var remainingTime:Number = DragonBreedingManager.getInstance(this.m_featureName).getVistingDragonTimeRemainingByItemCode(this.getVisitingDragonItemCode());
         if(remainingTime > 0)
         {
            result = Math.round(remainingTime / FarmGameUtil.NUM_SECS_IN_HOUR).toString();
         }
         return result;
      }
      
      private function showVisitingDragonIcon() : void
      {
         var visitingDragonItemCodeArray:Array = null;
         var visitingDragonItemCode:String = null;
         var vdItem:FarmItem = null;
         if(DragonBreedingManager.getInstance(this.m_featureName).toasterWindowType == DragonBreedingManager.TOASTER_SHOW_VISITING_DRAGON)
         {
            visitingDragonItemCodeArray = DragonBreedingManager.getInstance(this.m_featureName).getVisitingDragonItemCodeAsArray();
            visitingDragonItemCode = "";
            if(Boolean(visitingDragonItemCodeArray) && visitingDragonItemCodeArray.length > 0)
            {
               visitingDragonItemCode = visitingDragonItemCodeArray[0];
            }
            if(visitingDragonItemCode != "")
            {
               vdItem = Global.farmGameSettingsManager.getFarmItemByCode(visitingDragonItemCode);
               if(Boolean(vdItem) && m_window.hasOwnProperty(ICON_MC))
               {
                  new FarmIcon(this.m_iconMc = m_window[ICON_MC],vdItem.getImageByName("icon"));
               }
            }
         }
      }
      
      private function getBreedCompleteItemName(gender:String) : String
      {
         var itemCode:String = null;
         var itemName:String = null;
         var result:String = "";
         var breedParentObj:Object = this.getBreedCompleteParentDragons();
         if(Boolean(breedParentObj) && breedParentObj.hasOwnProperty(gender))
         {
            itemCode = breedParentObj[gender];
            itemName = (Global.farmGameSettingsManager.getFarmItemByCode(itemCode) as FarmItem).friendlyTitle;
            if(itemName)
            {
               result = itemName;
            }
         }
         return result;
      }
      
      private function getBreedCompleteParentDragons() : Object
      {
         var result:Object = null;
         var breedParentObj:Object = null;
         var breedCompleteParentItemObj:Array = DragonBreedingManager.getInstance(this.m_featureName).getBreedCompletedParentItems();
         if(Boolean(breedCompleteParentItemObj.length > 0) && Boolean(breedCompleteParentItemObj[0]) && Boolean(breedCompleteParentItemObj[0]))
         {
            breedParentObj = breedCompleteParentItemObj[0];
            if(breedParentObj)
            {
               result = breedParentObj;
            }
         }
         return result;
      }
      
      private function getHatchReadyItemName(gender:String) : String
      {
         var itemCode:String = null;
         var itemName:String = null;
         var result:String = "";
         var hatchReadyParentObj:Object = this.getHatchReadyParentDragonsObject();
         if(Boolean(hatchReadyParentObj) && hatchReadyParentObj.hasOwnProperty(gender))
         {
            itemCode = hatchReadyParentObj[gender];
            itemName = (Global.farmGameSettingsManager.getFarmItemByCode(itemCode) as FarmItem).friendlyTitle;
            if(itemName)
            {
               result = itemName;
            }
         }
         return result;
      }
      
      private function getHatchReadyParentDragonsObject() : Object
      {
         var result:Object = null;
         var hatchReadyParentObj:Object = null;
         var hatchReadyParentItems:Array = DragonBreedingManager.getInstance(this.m_featureName).getHatchReadyParentItems();
         if(hatchReadyParentItems.length > 0 && Boolean(hatchReadyParentItems[0]))
         {
            hatchReadyParentObj = hatchReadyParentItems[0];
            if(hatchReadyParentObj)
            {
               result = hatchReadyParentObj;
            }
         }
         return result;
      }
      
      private function onAcceptButtonClick(e:Event = null) : void
      {
         DragonBreedingManager.getInstance(this.m_featureName).openDragonBreedingUI();
         this.close();
      }
      
      override public function close() : void
      {
         DragonBreedingManager.getInstance(this.m_featureName).destoryToasterWindow();
         super.close();
      }
   }
}

