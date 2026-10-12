package Widgets.Windows.ConstructionBuilding
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ConstructionBuilding.ConstructionSelectSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   
   public class ConstructionSelectWindow extends FarmWindow
   {
      
      private const ICON_SIZE:Number = 50;
      
      private var m_buildingData:Array = null;
      
      private var m_constructionItem:FarmItem;
      
      private var m_addItemCallback:Function;
      
      public function ConstructionSelectWindow(buildingData:Array, constructionItem:FarmItem, addItemCallback:Function)
      {
         super("assets/dialogs/FV_ChooseProject.swf");
         this.m_buildingData = buildingData;
         this.m_constructionItem = constructionItem;
         this.m_addItemCallback = addItemCallback;
      }
      
      override protected function postLoadComplete() : void
      {
         var itemName:String = this.m_constructionItem.friendlyName;
         addWidget(new ZwTextField(m_window.giftsTitle_tf,ZLocUtils.t("Dialogs","ConstructionBuildingChooseJob_Title")));
         addWidget(new ZwTextField(m_window.chooseWhere_tf,ZLocUtils.t("Dialogs","ConstructionBuildingChooseJob_ChooseMessage",{"item":ZLocUtils.tk_pk(itemName)})));
         addWidget(new ZwTextField(m_window.itemTitle_tf,ZLocUtils.tk_pk_asTitle(itemName)));
         var itemIcon:FarmIcon = new FarmIcon(m_window.icon,this.m_constructionItem.icon);
         itemIcon.setIconSize(this.ICON_SIZE,this.ICON_SIZE);
         addWidget(itemIcon);
         addWidget(new FarmAnimatedButton(m_window.cancel_bt,onClose));
         addWidget(new ConstructionSelectSlotFrame(m_window.projectSelector_mc,this.m_buildingData,this.m_addItemCallback,this));
      }
   }
}

