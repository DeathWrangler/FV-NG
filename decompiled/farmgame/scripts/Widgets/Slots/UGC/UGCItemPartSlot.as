package Widgets.Slots.UGC
{
   import Classes.UGC.UGCConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.UGCDecoManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmItemIcon;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class UGCItemPartSlot extends ZwSlotFrame
   {
      
      private var m_farmItem:FarmItem;
      
      private var m_featureName:String = null;
      
      private var m_countTf:ZwTextField;
      
      private var m_cost:int;
      
      private var m_askBt:FarmAnimatedTextButton;
      
      private var m_buyBt:FarmAnimatedTextButton;
      
      public function UGCItemPartSlot(element:DisplayObject, part:FarmItem, featureName:String)
      {
         var str:String = null;
         var bText:String = null;
         var icon:FarmItemIcon = null;
         var buyText:String = null;
         var costText:String = null;
         super(element);
         this.m_farmItem = part;
         this.m_featureName = featureName;
         if(ObjectUtil.pathExists(m_element,"itemTitle_tf"))
         {
            str = ZLocUtils.tk_pk_asTitle(this.m_farmItem.friendlyName);
            addWidget(new ZwTextField(m_element["itemTitle_tf"],str));
         }
         if(ObjectUtil.pathExists(m_element,"alive_tf"))
         {
            this.m_countTf = new ZwTextField(m_element["alive_tf"],"0 of 0");
            addWidget(this.m_countTf);
         }
         if(ObjectUtil.pathExists(m_element,"getThis_bt"))
         {
            bText = ZLocUtils.t("Dialogs","UGC_Deco_Get_This");
            this.m_askBt = new FarmAnimatedTextButton(m_element.getThis_bt,bText,this.handleAskClicked);
            addWidget(this.m_askBt);
         }
         if(ObjectUtil.pathExists(m_element,"icon"))
         {
            icon = new FarmItemIcon(this,m_element.icon,part);
         }
         if(ObjectUtil.pathExists(m_element,"buy_bt"))
         {
            buyText = ZLocUtils.t("Dialogs","Buy");
            this.m_buyBt = new FarmAnimatedTextButton(m_element.buy_bt,buyText,this.handleBuyClicked);
            addWidget(this.m_buyBt);
         }
         if(ObjectUtil.pathExists(m_element,"fcPrice_mc"))
         {
            costText = "" + this.m_farmItem.cash;
            addWidget(new ZwTextField(m_element["fcPrice_mc"]["FCPrice_tf"],costText));
         }
         this.refresh();
      }
      
      private function handleAskClicked(e:Event) : void
      {
         dispatchEvent(new Event(UGCConstants.EVENT_ASK_FOR_MATERIALS));
         if(UGCDecoManager.instance.getMaterialAsk(this.m_farmItem.name) == "feed")
         {
            this.m_askBt.enabled = false;
            this.m_askBt.applyGrayOut = true;
         }
         var feedSource:String = UGCDecoManager.instance.getMaterialFeedSource(this.m_farmItem.name);
         FarmStatsManager.count("dialog","ugc_deco_dialog",feedSource,"","ask_parts");
         UGCDecoManager.instance.doSocialRequest(this.m_farmItem.name,feedSource,this.m_featureName,this.refresh);
      }
      
      private function handleBuyClicked(e:Event) : void
      {
         UGCDecoManager.instance.purchaseMaterial(this.m_farmItem,this.handlePurchaseReturn);
         dispatchEvent(new Event(UGCConstants.EVENT_MATERIAL_PURCHASED));
      }
      
      private function handlePurchaseReturn(result:Object) : void
      {
      }
      
      public function setCost(cost:Object) : void
      {
         this.m_cost = cost.hasOwnProperty(this.m_farmItem.name) ? int(cost[this.m_farmItem.name]) : 0;
         this.refresh();
      }
      
      public function refresh(result:Object = null) : void
      {
         var have:int = UGCDecoManager.instance.getPartCount(this.m_farmItem.name);
         this.m_countTf.text = "" + have + " of " + this.m_cost;
         if(ObjectUtil.pathExists(m_element,"checkmark_mc"))
         {
            m_element.checkmark_mc.visible = this.canBuy();
         }
         this.m_buyBt.enabled = have < UGCDecoManager.instance.getMaxByMaterial(this.m_farmItem.name);
         this.m_buyBt.applyGrayOut = !this.m_buyBt.enabled;
         if(UGCDecoManager.instance.getMaterialAsk(this.m_farmItem.name) == "feed")
         {
            this.m_askBt.enabled = UGCDecoManager.instance.canTakePostAction(UGCDecoManager.instance.getMaterialFeedSource(this.m_farmItem.name));
            this.m_askBt.applyGrayOut = !this.m_askBt.enabled;
         }
         else
         {
            this.m_askBt.enabled = this.m_buyBt.enabled;
            this.m_askBt.applyGrayOut = !this.m_buyBt.enabled;
         }
      }
      
      public function canBuy() : Boolean
      {
         return UGCDecoManager.instance.getPartCount(this.m_farmItem.name) >= this.m_cost;
      }
   }
}

