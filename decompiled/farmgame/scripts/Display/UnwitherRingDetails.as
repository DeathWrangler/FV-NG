package Display
{
   import Classes.Friend;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Utilities;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.*;
   
   public class UnwitherRingDetails extends Dialog
   {
      
      protected const RING_CODE:String = "1k";
      
      protected var m_senderID:String;
      
      protected var m_sender:Friend = Global.friendManager.getFriendData(this.m_senderID);
      
      protected var m_item:FarmItem;
      
      protected var m_message:String;
      
      protected var m_whatIsThisDialog:GenericPopup = null;
      
      public function UnwitherRingDetails(senderID:String, itemCode:String, message:String)
      {
         m_dialogAsset = "assets/dialogs/FV_Unwither_receive.swf";
         this.m_senderID = senderID;
         this.m_item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         this.m_message = message;
         super();
      }
      
      override protected function onLoadComplete() : void
      {
         var whatIsThisBtn:GenericButton;
         var reportBtn:GenericButton;
         var icon:Loader;
         super.onLoadComplete();
         m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onClose);
         whatIsThisBtn = new GenericButton(m_window.whatisthis_mc,this.onWhatIsThis,ZLocUtils.t("Dialogs","WhatIsThis"));
         m_window.whatIsThisBtn = whatIsThisBtn;
         reportBtn = new GenericButton(m_window.reportAbuse_bt,this.onReportAbuse,ZLocUtils.t("Dialogs","ReportAbuse"));
         m_window.reportBtn = reportBtn;
         m_window.title_tf.text = ZLocUtils.t("Dialogs","UnwitherRingDetailTitle");
         m_window.sentBy_tf.text = ZLocUtils.t("Dialogs","UnwitherRingDetailSentBy");
         m_window.metal_tf.text = ZLocUtils.t("Dialogs","UnwitherRingDetailMetalLabel");
         m_window.gem_tf.text = ZLocUtils.t("Dialogs","UnwitherRingDetailGemLabel");
         m_window.personalMsg_tf.text = ZLocUtils.t("Dialogs","UnwitherRingDetailMessageLabel");
         m_window.yourRing_tf.text = ZLocUtils.t("Dialogs","UnwitherRingDetailRingLabel");
         if(this.m_sender != null)
         {
            m_window.name_tf.text = this.m_sender.name;
         }
         else if(this.m_senderID == Global.player.uid)
         {
            m_window.name_tf.text = ZLocUtils.t("Dialogs","ValentinePresentNameSelf");
         }
         else
         {
            m_window.name_tf.text = ZLocUtils.t("Dialogs","ValentinePresentNameDefault");
         }
         if(Boolean(this.m_message) && this.m_message != "")
         {
            m_window.message_tf.text = this.m_message;
         }
         else
         {
            m_window.message_tf.text = ZLocUtils.t("Dialogs","CustomizeRingPersonalMessageDefaultText");
         }
         this.setupRingDetails();
         icon = LoadingManager.load(this.m_item.icon,function(event:Event):void
         {
            var dispObj:* = undefined;
            var icon:* = event.target;
            if(Boolean(icon) && Boolean(icon.content))
            {
               Utilities.removeAllChildren(m_window.ringImage_mc.ringIcon_mc);
               dispObj = icon.content;
               dispObj.width = 100;
               dispObj.height = 100;
               dispObj.x = (m_window.ringImage_mc.ringIcon_mc.width - dispObj.width) / 2;
               dispObj.y = (m_window.ringImage_mc.ringIcon_mc.height - dispObj.height) / 2;
               m_window.ringImage_mc.ringIcon_mc.addChild(dispObj);
            }
         });
      }
      
      protected function setupRingDetails() : void
      {
         var metalName:String = null;
         var itemName:String = this.m_item.name;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.RING_CODE);
         itemName = itemName.replace(/unwitherring/,"");
         var metalList:Array = item.getMetalList();
         for(var metalIDx:int = 0; metalIDx < metalList.length; metalIDx++)
         {
            if(itemName.indexOf(metalList[metalIDx].name) > -1)
            {
               metalName = metalList[metalIDx].name;
               m_window.ringType_tf.text = ZLocUtils.t("Dialogs",metalName);
               itemName = itemName.substring(itemName.indexOf(metalList[metalIDx].name) + metalName.length);
               if(itemName == "")
               {
                  itemName = "none";
               }
               m_window.gemType_tf.text = ZLocUtils.t("Dialogs",itemName);
            }
         }
      }
      
      protected function onReportAbuse(event:MouseEvent) : void
      {
         var abuseEmail:String = "mailto:farmvillereport@zynga.com?subject=Farmville Abuse for Facebook Id " + this.m_senderID;
         navigateToURL(new URLRequest(abuseEmail),"");
         this.onClose(event);
      }
      
      protected function onWhatIsThis(event:MouseEvent) : void
      {
         var msg:String = null;
         if(null == this.m_whatIsThisDialog)
         {
            msg = ZLocUtils.t("Dialogs","UnwitherRingDetailWhatIsThis");
            this.m_whatIsThisDialog = new GenericPopup(msg,GenericPopup.TYPE_OK,this.onWhatIsThisClose);
            UI.displayPopup(this.m_whatIsThisDialog,false,"whatIsThisDialong",true);
         }
      }
      
      protected function onWhatIsThisClose(event:Event) : void
      {
         this.m_whatIsThisDialog = null;
      }
      
      protected function onClose(event:MouseEvent) : void
      {
         m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onClose);
         m_window.whatIsThisBtn.turnOff();
         m_window.reportBtn.turnOff();
         if(this.m_whatIsThisDialog)
         {
            this.m_whatIsThisDialog.close();
         }
         close();
      }
   }
}

