package Init.PostInitActionHandlers
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import Widgets.Windows.IconTitleToasterWindow;
   import flash.geom.Point;
   
   public class GenericItemFlagToasterAction extends AbstractPostInitAction
   {
      
      protected var m_itemFlag:String;
      
      protected var m_message:String;
      
      protected var m_title:String;
      
      public function GenericItemFlagToasterAction(callback:Function, itemFlag:String)
      {
         super(callback);
         this.m_itemFlag = itemFlag;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(Global.player.getItemFlag(this.m_itemFlag));
         if(ZLocUtils.hasString("Dialogs","ItemFlag_" + this.m_itemFlag + "_Title"))
         {
            this.m_title = ZLocUtils.t("Dialogs","ItemFlag_" + this.m_itemFlag + "_Title");
         }
         else
         {
            this.m_title = ZLocUtils.t("Dialogs","ItemFlag_Generic_Title");
         }
         var friendlyName:String = item ? item.friendlyName : "";
         if(ZLocUtils.hasString("Dialogs","ItemFlag_" + this.m_itemFlag + "_Message"))
         {
            this.m_message = ZLocUtils.t("Dialogs","ItemFlag_" + this.m_itemFlag + "_Message",{"item":ZLocUtils.tk_pk(friendlyName)});
         }
         else
         {
            this.m_message = ZLocUtils.t("Dialogs","ItemFlag_Generic_Message",{"item":ZLocUtils.tk_pk(friendlyName)});
         }
      }
      
      override public function execute() : void
      {
         var toasterItem:FarmItem = null;
         var item:String = Global.player.getItemFlag(this.m_itemFlag);
         if(item != "")
         {
            toasterItem = Global.farmGameSettingsManager.getFarmItemByCode(item);
            if(toasterItem)
            {
               FarmStatsManager.count("ItemFlagToaster",this.m_itemFlag,toasterItem.name);
               ToasterManager.getInstance().add(new IconTitleToasterWindow(this.m_title,this.m_message,toasterItem.icon,"assets/dialogs/FV_Craft_BannerAd.swf",0.6,new Point(14,11),m_callback));
               Global.player.setItemFlag(this.m_itemFlag,"",true);
            }
         }
         m_isFinished = true;
      }
   }
}

