package Classes
{
   import Classes.ZItem.DecorationItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.view.TextFieldView;
   import flash.utils.getDefinitionByName;
   
   public class BuffDecoration extends Decoration
   {
      
      private static const PLACEMENT_DIALOG_TITLE_LOC_KEY:String = "_PlacementTitle";
      
      private static const PLACEMENT_DIALOG_BODY_LOC_KEY:String = "_PlacementBody";
      
      private var m_buff:Buff = null;
      
      public function BuffDecoration(itemName:String = null)
      {
         super(itemName);
      }
      
      override public function onPlacedFirstTime() : void
      {
         var buff:Buff = this.getBuff();
         if(Boolean(buff) && !buff.hasExceededUseLimit())
         {
            buff.apply(true);
            this.showPlacementDialog();
         }
      }
      
      protected function getBuff() : Buff
      {
         var buffItemName:String = null;
         var buffItem:FarmItem = null;
         var buffClass:Class = null;
         if(!this.m_buff)
         {
            buffItemName = (this.getItem() as DecorationItem).buffName;
            if(buffItemName)
            {
               buffItem = Global.farmGameSettingsManager.getFarmItemByName(buffItemName);
               if(buffItem)
               {
                  buffClass = getDefinitionByName("Classes.buffs." + buffItem.className) as Class;
                  this.m_buff = new buffClass(buffItemName);
               }
            }
         }
         return this.m_buff;
      }
      
      override protected function updateToolTipText() : void
      {
         var buff:Buff = null;
         var timeRemainingString:String = null;
         var toolTip:String = m_item.friendlyTitle;
         if(!Global.worldManager.isVisiting())
         {
            buff = this.getBuff();
            if(Boolean(buff) && !buff.isExpired())
            {
               timeRemainingString = FarmGameUtil.toFriendlyTime(this.getBuff().secondsRemaining);
               toolTip += " " + ZLocUtils.t("Dialogs","Remaining",{"time":timeRemainingString});
            }
            else
            {
               toolTip += " " + ZLocUtils.t("Dialogs","Remaining",{"time":"0"});
            }
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
      
      protected function showPlacementDialog() : void
      {
         var dialogParams:Array = [this.getPlacementTitleText(),this.getPlacementBodyText(),getItem().icon];
         var dialog:FarmDynamicDialog = FarmDynamicDialog.createDialog("buffDecorationPlacement",FarmDynamicDialog);
         dialog.setShortcutAttribute("titletext",TextFieldView.ATTRIBUTE_TEXT,this.getPlacementTitleText());
         dialog.setShortcutAttribute("itemImage",ImageController.ATTRIBUTE_SOURCE,getItem().icon);
         dialog.setShortcutAttribute("bodyText",TextFieldView.ATTRIBUTE_TEXT,this.getPlacementBodyText());
         dialog.setShortcutAttribute("okayButton",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Continue"));
         dialog.show();
      }
      
      private function getPlacementTitleText() : String
      {
         var locKey:String = getItem().name + PLACEMENT_DIALOG_TITLE_LOC_KEY;
         return ZLocUtils.t("Dialogs",locKey);
      }
      
      private function getPlacementBodyText() : String
      {
         var locKey:String = null;
         var timeRemaining:String = null;
         var expirationDate:Date = null;
         var expirationDateTime:String = null;
         var result:String = "";
         var buff:Buff = this.getBuff();
         if(Boolean(buff) && !buff.isExpired())
         {
            locKey = getItem().name + PLACEMENT_DIALOG_BODY_LOC_KEY;
            timeRemaining = FarmGameUtil.toFriendlyTime(this.getBuff().secondsRemaining);
            expirationDate = new Date(this.getBuff().expirationTime * 1000);
            expirationDateTime = ZLocUtils.formatDateTime(expirationDate);
            result = ZLocUtils.t("Dialogs",locKey,{
               "timeStr":timeRemaining,
               "dateStr":expirationDateTime
            });
         }
         return result;
      }
   }
}

