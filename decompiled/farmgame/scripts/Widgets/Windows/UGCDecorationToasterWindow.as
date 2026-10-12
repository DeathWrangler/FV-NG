package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.IUGCItem;
   import Classes.util.ZLocUtils;
   import Managers.UGCDecoManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   
   public class UGCDecorationToasterWindow extends ToasterWindow
   {
      
      private const SWF_NAME:String = "assets/dialogs/FV_UGC_BuildingToaster.swf";
      
      private var m_completedId:String;
      
      public function UGCDecorationToasterWindow(completedId:String)
      {
         super(this.SWF_NAME);
         this.m_completedId = completedId;
      }
      
      override protected function onShow() : void
      {
         super.onShow();
      }
      
      override protected function postLoadComplete() : void
      {
         var icon:FarmIcon = null;
         super.postLoadComplete();
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_completedId);
         var completed:String = ZLocUtils.tk_pk_asTitle(item.friendlyName);
         var subTitle:String = ZLocUtils.t("Dialogs","UGCDeco_BlueprintUnlocked_Title",{"building":completed});
         var text:String = ZLocUtils.t("Dialogs","UGCDeco_BlueprintUnlocked_Desc");
         var btnText:String = ZLocUtils.t("Dialogs","UGCDeco_BlueprintUnlocked_Btn");
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,btnText,this.handleOpenDialogClicked));
         addWidget(new ZwTextField(m_window.generic_tf,subTitle));
         addWidget(new ZwTextField(m_window.generic_desc_tf,text));
         icon = addWidget(new FarmIcon(m_window.icon_mc)) as FarmIcon;
         icon.loadIcon(item.iconUrl);
         icon.setIconScaleX(0.65);
         icon.setIconScaleY(0.65);
         icon.x -= 10;
         icon.y -= 15;
      }
      
      private function handleOpenDialogClicked(e:Event) : void
      {
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_completedId);
         UGCDecoManager.instance.showUGCDecoDialog(farmItem.gameSettingsFeatureName,farmItem as IUGCItem);
         this.close();
      }
   }
}

