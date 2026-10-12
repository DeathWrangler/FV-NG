package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.FeatureOptionsManager;
   import Managers.SubscriberWalletManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
   public class VIPPhoneFeatureWindow extends FarmWindow
   {
      
      public static var m_coolDownTime:uint;
      
      public static var m_windowDisplayCount:int;
      
      private static var m_eosVariables:Object;
      
      public static const VIP_PHONE_FEATURE_SEEN_FLAG:String = "VIP_Phone_V3_Feature_SEEN";
      
      public static const VIP_PHONE_FEATURE_SUBMIT_FLAG:String = "VIP_Phone_V3_Feature_Submitted";
      
      public static const COOL_DOWN_TIME:int = 864000;
      
      public static const VIP_COOLDOWN_TIMER_KEY:String = "Cooldown_timer_key";
      
      public static const VIP_PHONE_FEATURE_COUNT:String = "Feature_Seen_Count";
      
      private static const FEATURE_NAME:String = "VIPPhoneFeatureV3";
      
      private var m_phone_error:ZwTextField;
      
      private var m_name_error:ZwTextField;
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      private var m_checkbox_mc:ZwWidget;
      
      private var m_select_mc:MovieClip;
      
      private var name1_tf:*;
      
      private var name2_tf:*;
      
      private var phone1_tf:*;
      
      private var phone2_tf:*;
      
      private var phone3_tf:*;
      
      private var tickcheck:* = false;
      
      private var m_close_bt:*;
      
      private var phoneNumber:String;
      
      private const SERVICE_NAME:String = "VIPPhoneFeatureWindowService";
      
      private var name1_Obj:Object = new Object();
      
      private var name2_Obj:Object = new Object();
      
      private var phone1_Obj:Object = new Object();
      
      private var phone2_Obj:Object = new Object();
      
      private var phone3_Obj:Object = new Object();
      
      private var m_generictf:ZwTextField;
      
      private var privacyTf:ZwTextField;
      
      public function VIPPhoneFeatureWindow(dialogPath:String)
      {
         super(dialogPath);
      }
      
      public static function launchVipPhoneFeature() : void
      {
         var isItVip:Boolean = false;
         m_eosVariables = Global.eosManager.getEosVariables("fv_vipphonecollection");
         if(Boolean(m_eosVariables) && Boolean(m_eosVariables.isEnabled))
         {
            m_windowDisplayCount = m_eosVariables.WindowDisplayCount;
            m_coolDownTime = m_eosVariables.CoolDownDays * 24 * 60 * 60;
            isItVip = SubscriberWalletManager.getInstance().isVip();
            if(isItVip != null && !Global.player.getSeenFlag(VIP_PHONE_FEATURE_SUBMIT_FLAG) && isTimerReset() && FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,VIP_PHONE_FEATURE_COUNT) < m_windowDisplayCount)
            {
               UI.displayPopup(new VIPPhoneFeatureWindow("assets/dialogs/FV_VIP_PhoneNumberCollection_2020/FV_PhoneNumberCollection_2020.swf"),false);
               StatsManager.count("VIP_PhoneCollection","Impression",String(FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,VIP_PHONE_FEATURE_COUNT)),"","",Global.worldManager.currentWorldType);
            }
         }
      }
      
      public static function launchVipPhoneFeatureFromMessageBoard() : void
      {
         var isItVip:Boolean = false;
         m_eosVariables = Global.eosManager.getEosVariables("fv_vipphonecollection");
         if(Boolean(m_eosVariables) && Boolean(m_eosVariables.isEnabled))
         {
            m_windowDisplayCount = m_eosVariables.WindowDisplayCount;
            m_coolDownTime = m_eosVariables.CoolDownDays * 24 * 60 * 60;
            isItVip = SubscriberWalletManager.getInstance().isVip();
            if(isItVip != null && !Global.player.getSeenFlag(VIP_PHONE_FEATURE_SUBMIT_FLAG))
            {
               UI.displayPopup(new VIPPhoneFeatureWindow("assets/dialogs/FV_VIP_PhoneNumberCollection_2020/FV_PhoneNumberCollection_2020.swf"),false);
               StatsManager.count("VIP_PhoneCollection","Impression",String(FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,VIP_PHONE_FEATURE_COUNT)),"","",Global.worldManager.currentWorldType);
            }
         }
      }
      
      public static function getTimeLeft(key:String, throttleTime:int) : int
      {
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return int(timeSinceLastFeed - throttleTime);
      }
      
      public static function isTimerReset() : Boolean
      {
         var resetTrue:Boolean = false;
         var key:String = VIP_COOLDOWN_TIMER_KEY;
         if(getTimeLeft(key,m_coolDownTime) > 0)
         {
            resetTrue = true;
         }
         return resetTrue;
      }
      
      public function checkIfAllFieldsAreValid(e:Event) : void
      {
         if(Boolean(this.name1_Obj.check) && Boolean(this.name2_Obj.check) && Boolean(this.phone1_Obj.check) && Boolean(this.phone2_Obj.check) && Boolean(this.phone3_Obj.check))
         {
            this.m_accept_bt.enabled = true;
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addEventListener(Event.ENTER_FRAME,this.checkIfAllFieldsAreValid);
         if(m_window.hasOwnProperty("generic_tf"))
         {
            addWidget(this.m_generictf = new ZwTextField(m_window["generic_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vip_phone_feature_generic")));
            this.m_generictf.visible = true;
         }
         if(m_window.hasOwnProperty("checkbox_tf"))
         {
            addWidget(new ZwTextField(m_window["checkbox_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vip_phone_feature_checkbox_text")));
         }
         if(m_window.hasOwnProperty("name1_tf"))
         {
            addWidget(this.name1_Obj.tf = new ZwTextField(m_window["name1_tf"],"First Name"));
            this.name1_tf = m_window["name1_tf"];
         }
         if(m_window.hasOwnProperty("name2_tf"))
         {
            addWidget(this.name2_Obj.tf = new ZwTextField(m_window["name2_tf"],"Last Name"));
            this.name2_tf = m_window["name2_tf"];
         }
         if(m_window.hasOwnProperty("phone1_tf"))
         {
            addWidget(this.phone1_Obj.tf = new ZwTextField(m_window["phone1_tf"],"000"));
            this.phone1_tf = m_window["phone1_tf"];
         }
         if(m_window.hasOwnProperty("phone2_tf"))
         {
            addWidget(this.phone2_Obj.tf = new ZwTextField(m_window["phone2_tf"],"000"));
            this.phone2_tf = m_window["phone2_tf"];
         }
         if(m_window.hasOwnProperty("phone3_tf"))
         {
            addWidget(this.phone3_Obj.tf = new ZwTextField(m_window["phone3_tf"],"0000"));
            this.phone3_tf = m_window["phone3_tf"];
         }
         if(m_window.hasOwnProperty("phoneError_tf"))
         {
            addWidget(this.m_phone_error = new ZwTextField(m_window["phoneError_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vip_phone_feature_phone_error")));
            this.m_phone_error.visible = false;
         }
         if(m_window.hasOwnProperty("nameError_tf"))
         {
            addWidget(this.m_name_error = new ZwTextField(m_window["nameError_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vip_phone_feature_name_error")));
            this.m_name_error.visible = false;
         }
         if(m_window.hasOwnProperty("callout_tf"))
         {
            addWidget(new ZwTextField(m_window["callout_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vip_phone_feature_callout_text")));
         }
         if(m_window.hasOwnProperty("name1_mc"))
         {
            this.name1_Obj.mc = m_window["name1_mc"] as MovieClip;
            this.name1_Obj.mc.visible = true;
         }
         if(m_window.hasOwnProperty("name2_mc"))
         {
            this.name2_Obj.mc = m_window["name2_mc"] as MovieClip;
            this.name2_Obj.mc.visible = true;
         }
         if(m_window.hasOwnProperty("phone1_mc"))
         {
            this.phone1_Obj.mc = m_window["phone1_mc"] as MovieClip;
            this.phone1_Obj.mc.visible = true;
         }
         if(m_window.hasOwnProperty("phone2_mc"))
         {
            this.phone2_Obj.mc = m_window["phone2_mc"] as MovieClip;
            this.phone2_Obj.mc.visible = true;
         }
         if(m_window.hasOwnProperty("phone3_mc"))
         {
            this.phone3_Obj.mc = m_window["phone3_mc"] as MovieClip;
            this.phone3_Obj.mc.visible = true;
         }
         if(m_window.hasOwnProperty("link1_tf"))
         {
            addWidget(new ZwTextField(m_window["link1_tf"],"Text"));
            m_window["link1_tf"].htmlText = "<a href=\"https://www.zynga.com/legal/terms-of-service\"style=\'text-decoration: underline;\' target=\'_blank\' style=\"cursor: pointer;\">Terms of Service</a>";
         }
         if(m_window.hasOwnProperty("link2_tf"))
         {
            addWidget(new ZwTextField(m_window["link2_tf"],"Text"));
            m_window["link2_tf"].htmlText = "<a href=\"https://www.zynga.com/privacy/policy\" style=\'text-decoration: underline;\' target=\'_blank\' style=\"cursor: pointer;\">Privacy Policy</a>";
         }
         if(m_window.hasOwnProperty("close_bt"))
         {
            this.m_close_bt = m_window["close_bt"];
            this.m_close_bt.addEventListener(MouseEvent.CLICK,this.closeVipFeatureWindow);
         }
         if(m_window.hasOwnProperty("accept_bt"))
         {
            addWidget(this.m_accept_bt = new FarmAnimatedTextButton(m_window["accept_bt"],"Submit",this.onSubmit));
            this.m_accept_bt.text = "Submit";
            this.m_accept_bt.enabled = false;
         }
         if(m_window.hasOwnProperty("select_bt"))
         {
            this.m_select_mc = m_window["select_bt"] as MovieClip;
            this.m_select_mc.addEventListener(MouseEvent.CLICK,this.onClick);
            this.m_select_mc.visible = true;
         }
         this.name1_Obj.check = false;
         this.name1_Obj.Type = "name";
         this.name1_Obj.isCleared = false;
         this.name2_Obj.check = false;
         this.name2_Obj.Type = "name";
         this.name2_Obj.isCleared = false;
         this.phone1_Obj.check = false;
         this.phone1_Obj.Type = "phone";
         this.phone1_Obj.isCleared = false;
         this.phone1_Obj.MaxLength = 3;
         this.phone2_Obj.check = false;
         this.phone2_Obj.Type = "phone";
         this.phone2_Obj.isCleared = false;
         this.phone2_Obj.MaxLength = 3;
         this.phone3_Obj.check = false;
         this.phone3_Obj.Type = "phone";
         this.phone3_Obj.isCleared = false;
         this.phone3_Obj.MaxLength = 4;
         this.name1_tf.addEventListener(KeyboardEvent.KEY_UP,this.validateFields(this.name1_Obj));
         this.name2_tf.addEventListener(KeyboardEvent.KEY_UP,this.validateFields(this.name2_Obj));
         this.phone1_tf.addEventListener(KeyboardEvent.KEY_UP,this.validateFields(this.phone1_Obj));
         this.phone2_tf.addEventListener(KeyboardEvent.KEY_UP,this.validateFields(this.phone2_Obj));
         this.phone3_tf.addEventListener(KeyboardEvent.KEY_UP,this.validateFields(this.phone3_Obj));
         this.name1_tf.addEventListener(MouseEvent.CLICK,this.clearFields(this.name1_Obj));
         this.name2_tf.addEventListener(MouseEvent.CLICK,this.clearFields(this.name2_Obj));
         this.phone1_tf.addEventListener(MouseEvent.CLICK,this.clearFields(this.phone1_Obj));
         this.phone2_tf.addEventListener(MouseEvent.CLICK,this.clearFields(this.phone2_Obj));
         this.phone3_tf.addEventListener(MouseEvent.CLICK,this.clearFields(this.phone3_Obj));
      }
      
      private function clearFields(fieldObject:Object) : Function
      {
         return function(evt:MouseEvent):void
         {
            if(fieldObject.isCleared == false)
            {
               fieldObject.tf.text = "";
               fieldObject.isCleared = true;
            }
         };
      }
      
      private function validateFields(fieldObject:Object) : Function
      {
         return function(evt:KeyboardEvent):void
         {
            var i:* = undefined;
            var keychar:* = undefined;
            var temp_field_text:* = fieldObject.tf.text;
            var validCounter:* = 0;
            var length:* = temp_field_text.length;
            if(fieldObject.Type == "name")
            {
               if(length == 0)
               {
                  fieldObject.mc.gotoAndStop(1);
                  fieldObject.check = false;
               }
               else
               {
                  for(i = 0; i < length; )
                  {
                     keychar = temp_field_text.charAt(i);
                     if(keychar >= "A" && keychar <= "Z" || keychar >= "a" && keychar <= "z")
                     {
                        validCounter++;
                     }
                     i++;
                  }
                  if(validCounter == length)
                  {
                     fieldObject.mc.gotoAndStop(3);
                     m_name_error.visible = false;
                     fieldObject.check = true;
                  }
                  else
                  {
                     fieldObject.mc.gotoAndStop(2);
                     m_name_error.visible = true;
                     fieldObject.check = false;
                  }
               }
            }
            else if(length == 0)
            {
               fieldObject.mc.gotoAndStop(1);
               fieldObject.check = false;
               m_phone_error.visible = false;
            }
            else
            {
               for(i = 0; i < length; )
               {
                  keychar = temp_field_text.charAt(i);
                  if(keychar >= "0" && keychar <= "9")
                  {
                     validCounter++;
                  }
                  i++;
               }
               if(validCounter == length && length == fieldObject.MaxLength)
               {
                  fieldObject.mc.gotoAndStop(3);
                  m_phone_error.visible = false;
                  fieldObject.check = true;
               }
               else
               {
                  fieldObject.mc.gotoAndStop(2);
                  m_phone_error.visible = true;
                  fieldObject.check = false;
               }
            }
         };
      }
      
      private function onClick(evt:MouseEvent) : void
      {
      }
      
      private function closeVipFeatureWindow(evt:MouseEvent) : void
      {
         var key:String = null;
         var featureSeenCount:int = 0;
         StatsManager.count("VIP_PhoneCollection","CloseUI",String(FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,VIP_PHONE_FEATURE_COUNT)),"","",Global.worldManager.currentWorldType);
         var VIP_View_Count:Number = FeatureOptionsInventoryManager.getInstance().getCount(VIP_PHONE_FEATURE_COUNT);
         if(VIP_View_Count <= m_windowDisplayCount - 1)
         {
            key = VIP_COOLDOWN_TIMER_KEY;
            Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
            removeEventListener(Event.ENTER_FRAME,this.checkIfAllFieldsAreValid);
            featureSeenCount = int(FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,VIP_PHONE_FEATURE_COUNT));
            featureSeenCount += 1;
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,VIP_PHONE_FEATURE_COUNT,featureSeenCount);
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"onVIPFeatureClosed",null,[m_windowDisplayCount]));
         }
         else
         {
            Global.player.setSeenFlag(VIP_PHONE_FEATURE_SEEN_FLAG);
         }
      }
      
      private function onSubmit(evt:MouseEvent) : void
      {
         VIPPhoneFeatureRewardWindow.launchVIPphoneRewardfeature();
         removeEventListener(Event.ENTER_FRAME,this.checkIfAllFieldsAreValid);
         this.phoneNumber = "(" + this.phone1_Obj.tf.text + ")" + " " + this.phone2_Obj.tf.text + "-" + this.phone3_Obj.tf.text;
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_NAME,"sendData",this.onComplete,[this.phoneNumber,m_windowDisplayCount]));
         close();
      }
      
      private function onComplete(result:Object) : void
      {
         if(Boolean(result.success) && Boolean(result.hasOwnProperty("submit")) && result["submit"] == "success")
         {
            Global.player.addGift("pegacorn_snowy","0",1);
            StatsManager.count("VIP_PhoneCollection","Submit",String(FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,VIP_PHONE_FEATURE_COUNT)),"Success","",Global.worldManager.currentWorldType);
            Global.player.setSeenFlag(VIP_PHONE_FEATURE_SUBMIT_FLAG);
         }
         else
         {
            StatsManager.count("VIP_PhoneCollection","Submit",String(FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,VIP_PHONE_FEATURE_COUNT)),"Failure",Global.worldManager.currentWorldType);
         }
      }
   }
}

