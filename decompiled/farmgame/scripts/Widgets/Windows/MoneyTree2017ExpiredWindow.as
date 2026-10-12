package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class MoneyTree2017ExpiredWindow extends FarmWindow
   {
      
      private var m_featureName:String = null;
      
      private var m_activeName:String = "";
      
      private var m_treesIcon_mc:MovieClip;
      
      private var m_goldenTree_mc:MovieClip;
      
      private var m_crystallineTree_mc:MovieClip;
      
      private const SIZE_MC:String = "size_mc";
      
      private var m_size_mc:MovieClip;
      
      private const GIFTBOX_MC:String = "in_giftbox_mc";
      
      private var m_giftBox_mc:MovieClip;
      
      public function MoneyTree2017ExpiredWindow(featureName:String, windowUrl:String, itemName:String = "")
      {
         this.m_featureName = featureName;
         this.m_activeName = itemName;
         super(windowUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var item:FarmItem = null;
         super.postLoadComplete();
         m_window.visible = true;
         if(m_window)
         {
            if(m_window.hasOwnProperty("title_tf"))
            {
               addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_activeName + "_title_expired")));
            }
            if(this.m_activeName != "" && m_window.hasOwnProperty("icon_mc"))
            {
               this.m_treesIcon_mc = m_window["icon_mc"] as MovieClip;
               this.m_treesIcon_mc.visible = true;
               this.m_goldenTree_mc = this.m_treesIcon_mc["Tree_1_mc"] as MovieClip;
               this.m_crystallineTree_mc = this.m_treesIcon_mc["Tree_2_mc"] as MovieClip;
               if(this.m_activeName == "goldbillsprosperytree")
               {
                  this.m_goldenTree_mc.visible = true;
                  this.m_crystallineTree_mc.visible = false;
               }
               else if(this.m_activeName == "silverbillsprosperytree")
               {
                  this.m_goldenTree_mc.visible = false;
                  this.m_crystallineTree_mc.visible = true;
               }
            }
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_activeName);
            if(m_window.hasOwnProperty("generic_tf"))
            {
               addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_activeName + "_expired")));
            }
            if(m_window.hasOwnProperty(this.SIZE_MC))
            {
               this.m_size_mc = m_window[this.SIZE_MC] as MovieClip;
               this.m_size_mc.visible = true;
            }
            if(m_window.hasOwnProperty(this.GIFTBOX_MC))
            {
               this.m_giftBox_mc = m_window[this.GIFTBOX_MC] as MovieClip;
               this.m_giftBox_mc.visible = false;
            }
            if(m_window.okay_bt)
            {
               m_closeButton = addWidget(new FarmAnimatedTextButton(m_window.okay_bt,"Okay!",this.onCloseButtonClick)) as FarmAnimatedTextButton;
            }
         }
      }
      
      private function onCloseButtonClick(e:Event) : void
      {
         close();
      }
   }
}

