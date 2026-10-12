package Widgets.Slots.UGC
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   
   public class UGCDecoItemLayerItemSlot extends UGCItemLayerItemSlot
   {
      
      public function UGCDecoItemLayerItemSlot(element:DisplayObject)
      {
         super(element);
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         var textField:ZwTextField = getWidget("generic_tf") as ZwTextField;
         textField.text = ZLocUtils.tk_pk_asTitle(m_item.friendlyName);
      }
   }
}

