package Display
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import flash.events.MouseEvent;
   
   public class ShareFlowersDialog extends GenericIconPopup
   {
      
      protected var m_buildingName:String;
      
      protected var m_itemName:String;
      
      protected var m_maxItems:int;
      
      protected var m_selectedItems:int;
      
      public function ShareFlowersDialog(itemName:String, maxItems:int, buildingName:String, closeCallback:Function)
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         super(ZLocUtils.t("Dialogs","SelectShareMessage_" + buildingName,{"item":ZLocUtils.tk_pk(item.friendlyName)}),GenericPopup.TYPE_ACCEPTCANCEL,closeCallback,item.icon);
         this.m_itemName = itemName;
         this.m_maxItems = maxItems;
         this.m_selectedItems = this.m_maxItems;
         this.m_buildingName = buildingName;
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         m_window.popupBox_mc.okay_bt.visible = false;
         m_window.popupBox_mc.share_bt.visible = true;
         m_window.popupBox_mc.cancel_bt.visible = true;
         m_accept = new GenericButton(m_window.popupBox_mc.share_bt,onAccept);
         m_accept.text = ZLocUtils.t("Dialogs","ShareItem");
         m_reject = new GenericButton(m_window.popupBox_mc.cancel_bt,onCancel);
         m_reject.text = ZLocUtils.t("Dialogs","Cancel");
         m_window.popupBox_mc.bouquets_mc.bouquets_tf.text = ZLocUtils.t("Dialogs","SelectShareLabel_" + this.m_buildingName);
         m_window.popupBox_mc.bouquets_mc.visible = true;
         m_window.popupBox_mc.bouquets_mc.number_tf.text = String(this.m_maxItems);
         m_window.popupBox_mc.bouquets_mc.arrowUp_bt.addEventListener(MouseEvent.CLICK,this.onArrowUp,false,0,true);
         m_window.popupBox_mc.bouquets_mc.arrowDown_bt.addEventListener(MouseEvent.CLICK,this.onArrowDown,false,0,true);
      }
      
      protected function onArrowUp(event:MouseEvent) : void
      {
         if(this.m_selectedItems < this.m_maxItems)
         {
            ++this.m_selectedItems;
            this.updateNumberBox();
         }
      }
      
      protected function onArrowDown(event:MouseEvent) : void
      {
         if(this.m_selectedItems > 1)
         {
            --this.m_selectedItems;
            this.updateNumberBox();
         }
      }
      
      protected function updateNumberBox() : void
      {
         m_window.popupBox_mc.bouquets_mc.number_tf.text = String(this.m_selectedItems);
      }
      
      public function getItemCount() : int
      {
         return this.m_selectedItems;
      }
   }
}

