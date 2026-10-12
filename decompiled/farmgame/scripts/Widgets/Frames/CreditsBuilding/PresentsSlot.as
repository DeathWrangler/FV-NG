package Widgets.Frames.CreditsBuilding
{
   import Classes.FeaturePresent;
   import Classes.Friend;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class PresentsSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private static const LOC_BUNDLE:String = "Dialogs";
      
      private var m_data:FeaturePresent;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_userIcon:FarmIcon;
      
      private var m_giftIcon:FarmIcon;
      
      private var m_bowFrame:ZwFrame;
      
      private var m_bodyFrame:ZwFrame;
      
      private var m_bodyTextField:ZwTextField;
      
      private var m_redeemButton:FarmAnimatedTextButton;
      
      private var m_openPresentCallback:Function;
      
      private var m_featureName:String;
      
      public function PresentsSlot(element:DisplayObject, openPresentCallback:Function, featureName:String = null)
      {
         this.m_openPresentCallback = openPresentCallback;
         this.m_featureName = featureName ? featureName : "RewardCredits";
         super(element);
         this.m_userIcon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_userIcon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_giftIcon = addWidget(new FarmIcon(m_element.icon2_mc)) as FarmIcon;
         this.m_giftIcon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.itemTitle_tf)) as ZwTextField;
         this.m_bodyFrame = addWidget(new ZwFrame(m_element.dontOpen_mc)) as ZwFrame;
         this.m_bodyTextField = this.m_bodyFrame.addWidget(new ZwTextField(m_element.dontOpen_mc.costs_tf,"")) as ZwTextField;
         this.m_bowFrame = addWidget(new ZwFrame(m_element.bow_mc)) as ZwFrame;
         this.m_redeemButton = addWidget(new FarmAnimatedTextButton(m_element.use_bt,"",this.onOpenButtonClick)) as FarmAnimatedTextButton;
      }
      
      override public function populate(data:Object) : void
      {
         var openDate:String = null;
         var validToOpen:Boolean = false;
         var friendObj:Friend = null;
         var splitNames:Array = null;
         var shortName:String = null;
         var presentItem:FarmItem = null;
         super.populate(data);
         this.m_data = data as FeaturePresent;
         if(this.m_data)
         {
            if(this.m_data.friendId)
            {
               friendObj = Global.friendManager.getAppFriendData(this.m_data.friendId);
               if(friendObj)
               {
                  splitNames = friendObj.name.split(" ",2);
                  shortName = friendObj.firstName;
                  if(splitNames.length == 2)
                  {
                     shortName = splitNames[0] + " " + splitNames[1].toString().charAt(0) + ".";
                  }
                  shortName = ZLocUtils.t(LOC_BUNDLE,this.m_featureName + "_PresentFromText",{"user":ZLocUtils.tn(shortName,ZLocUtils.tg(friendObj.snUser.gender))});
                  this.m_nameTextField.text = shortName;
                  this.m_nameTextField.visible = true;
                  this.m_userIcon.loadIcon(friendObj.snUser.picture);
                  this.m_userIcon.visible = true;
               }
            }
            openDate = Global.farmGameSettingsManager.getAttribute(this.m_featureName + "OpenPresentDate");
            validToOpen = FarmGameUtil.synchronizedDateToNumber(openDate) < GlobalEngine.serverTime;
            if(validToOpen)
            {
               this.m_bodyFrame.visible = false;
               this.m_redeemButton.text = ZLocUtils.t(LOC_BUNDLE,this.m_featureName + "_PresentButtonText");
               this.m_redeemButton.visible = true;
            }
            else
            {
               this.m_bodyFrame.visible = true;
               this.m_bodyTextField.text = ZLocUtils.t(LOC_BUNDLE,this.m_featureName + "_PresentBodyText_Restricted");
               this.m_bodyTextField.visible = true;
            }
            if(this.m_data.openTimestamp)
            {
               this.m_bowFrame.visible = false;
               this.m_bodyFrame.visible = false;
               this.m_redeemButton.visible = false;
               presentItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data.presentItemCode);
               if(presentItem != null)
               {
                  this.m_giftIcon.loadIcon(presentItem.icon);
                  this.m_giftIcon.visible = true;
                  this.m_giftIcon.detachTooltip();
                  this.m_giftIcon.attachTooltip(new FarmTextTooltip(ZLocUtils.tk_pk_asTitle(presentItem.friendlyName)));
               }
            }
            else
            {
               this.m_bowFrame.visible = true;
               this.m_giftIcon.visible = false;
            }
         }
      }
      
      public function get data() : FeaturePresent
      {
         return this.m_data;
      }
      
      private function onOpenButtonClick(evt:Event) : void
      {
         if(this.m_openPresentCallback != null && Boolean(this.m_data))
         {
            this.m_openPresentCallback(this.m_data);
         }
      }
      
      override public function release() : void
      {
         this.m_data = null;
         this.m_nameTextField = null;
         this.m_userIcon = null;
         this.m_bowFrame = null;
         this.m_bodyFrame = null;
         this.m_bodyTextField = null;
         this.m_redeemButton = null;
         this.m_openPresentCallback = null;
         super.release();
      }
   }
}

