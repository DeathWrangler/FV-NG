package Widgets.Frames
{
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.OrderBoard.FrontierInnovationManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.FrontierInnovationCraftingSlot;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FrontierInnovationCraftingSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String;
      
      private var m_manager:FrontierInnovationManager = FrontierInnovationManager.getInstance(this.m_featureName);
      
      public var m_items:Object;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_pageTf:ZwTextField;
      
      private var m_highlightMc:ZwFrame;
      
      private var m_transessionMc:MovieClip;
      
      private var m_transessionRMc:MovieClip;
      
      private var m_tag0Mc:ZwWidget;
      
      private var m_tag1Mc:ZwWidget;
      
      private var m_tag2Mc:ZwWidget;
      
      internal var m_itemHoverTooltip:FarmTextTooltip;
      
      private const TRANSESSION_MC:String = "transession_mc";
      
      private const TRANSESSIONR_MC:String = "transessionR_mc";
      
      private const TAG0_MC:String = "tag0_mc";
      
      private const TAG1_MC:String = "tag1_mc";
      
      private const TAG2_MC:String = "tag2_mc";
      
      private const SpecialTagInfo:String = "Craft this item to sell it for 50% more Frontier Coins";
      
      private var m_TotalPages:uint;
      
      public function FrontierInnovationCraftingSlotFrame(element:DisplayObject, featureName:String, manager:Object)
      {
         this.m_featureName = featureName;
         super(element);
         if(m_element.hasOwnProperty("back_bt"))
         {
            m_pageBackWidget = addWidget(new ZwButton(m_element["back_bt"],this.onPageBack)) as ZwButton;
            if(m_pagingComponent.currentPageNumber == 0)
            {
               m_pageBackWidget.visible = false;
            }
         }
         if(m_element.hasOwnProperty("next_bt"))
         {
            m_pageForwardWidget = addWidget(new ZwButton(m_element["next_bt"],this.onPageForward)) as ZwButton;
         }
         if(m_element.hasOwnProperty("highlight_mc"))
         {
            this.m_highlightMc = new ZwFrame(m_element["highlight_mc"]);
            this.m_highlightMc.visible = true;
         }
         if(m_element.hasOwnProperty("body_tf"))
         {
            this.m_bodyTf = addWidget(new ZwTextField(m_element["body_tf"],"Craft the items below to get Frontier Coinage!")) as ZwTextField;
            this.m_bodyTf.visible = true;
         }
         if(m_element.hasOwnProperty("page_tf"))
         {
            this.m_pageTf = addWidget(new ZwTextField(m_element["page_tf"],"")) as ZwTextField;
            this.m_pageTf.visible = true;
         }
         if(m_element.hasOwnProperty(this.TRANSESSION_MC))
         {
            this.m_transessionMc = m_element[this.TRANSESSION_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(this.TRANSESSIONR_MC))
         {
            this.m_transessionRMc = m_element[this.TRANSESSIONR_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(this.TAG0_MC))
         {
            this.m_tag0Mc = addWidget(new ZwWidget(m_element[this.TAG0_MC])) as ZwWidget;
         }
         if(m_element.hasOwnProperty(this.TAG1_MC))
         {
            this.m_tag1Mc = addWidget(new ZwWidget(m_element[this.TAG1_MC])) as ZwWidget;
         }
         if(m_element.hasOwnProperty(this.TAG2_MC))
         {
            this.m_tag2Mc = addWidget(new ZwWidget(m_element[this.TAG2_MC])) as ZwWidget;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new FrontierInnovationCraftingSlot(slotElement,this.m_featureName,this.m_manager);
      }
      
      public function onPageBack(event:Event) : void
      {
         this.pageBack();
      }
      
      public function onPageForward(event:Event) : void
      {
         this.pageForward();
      }
      
      protected function pageBack() : void
      {
         FarmStatsManager.count(this.m_featureName,"PageScroll",m_pagingComponent.currentPageNumber.toString(),"Left");
         this.m_transessionMc.visible = true;
         this.m_transessionMc.play();
         this.m_highlightMc.visible = true;
         if(m_pagingComponent.currentPageNumber > 0)
         {
            --m_pagingComponent.currentPageNumber;
         }
         if(m_pagingComponent.currentPageNumber == 0)
         {
            this.m_highlightMc.visible = true;
         }
         this.conditionOnPagination();
         this.setPagination();
      }
      
      protected function pageForward() : void
      {
         FarmStatsManager.count(this.m_featureName,"PageScroll",m_pagingComponent.currentPageNumber.toString(),"Right");
         this.m_transessionRMc.visible = true;
         this.m_transessionRMc.play();
         this.m_highlightMc.visible = true;
         if(m_pagingComponent.currentPageNumber < m_pagingComponent.maxPageNumber)
         {
            m_pagingComponent.currentPageNumber += 1;
         }
         this.conditionOnPagination();
         this.setPagination();
      }
      
      private function conditionOnPagination() : void
      {
         if(m_pagingComponent.currentPageNumber == 0)
         {
            m_pageBackWidget.visible = false;
            this.m_itemHoverTooltip = new FarmTextTooltip(this.SpecialTagInfo);
            this.m_tag0Mc.visible = true;
            this.m_tag0Mc.attachTooltip(this.m_itemHoverTooltip);
            this.m_tag1Mc.visible = true;
            this.m_tag1Mc.attachTooltip(this.m_itemHoverTooltip);
            this.m_tag2Mc.visible = true;
            this.m_tag2Mc.attachTooltip(this.m_itemHoverTooltip);
         }
         else
         {
            m_pageBackWidget.visible = true;
            this.m_tag0Mc.visible = false;
            this.m_tag1Mc.visible = false;
            this.m_tag2Mc.visible = false;
         }
         if(m_pagingComponent.currentPageNumber == m_pagingComponent.maxPageNumber)
         {
            m_pageForwardWidget.visible = false;
         }
         else
         {
            m_pageForwardWidget.visible = true;
         }
      }
      
      public function getTotalPages() : uint
      {
         m_pagingComponent.maxPageNumber = int(m_slotData.length / totalSlots());
         if(m_slotData.length % totalSlots() != 0)
         {
            m_pagingComponent.maxPageNumber += 1;
         }
         return m_pagingComponent.maxPageNumber;
      }
      
      override protected function setupData() : void
      {
         var recipeObject:* = undefined;
         var i:* = 0;
         this.m_items = {};
         var m_slotDataTemp:Array = [];
         var m_sortedSlotData:Array = [];
         var recipe1:* = null;
         var recipe2:* = null;
         var recipe3:* = null;
         this.m_items = this.m_manager.parseCraftingRecipes();
         var allSpecialRecipes:Object = this.m_manager.getSpecialRecipes();
         if(allSpecialRecipes != null)
         {
            recipe1 = allSpecialRecipes[0][0];
            recipe2 = allSpecialRecipes[0][1];
            recipe3 = allSpecialRecipes[0][2];
         }
         var counter:int = 0;
         for each(recipeObject in this.m_items)
         {
            if(counter != parseInt(recipe1) && counter != parseInt(recipe2) && counter != parseInt(recipe3))
            {
               m_slotDataTemp.push(recipeObject);
            }
            counter++;
         }
         m_sortedSlotData = this.sortByResources(m_slotDataTemp);
         this.m_items[parseInt(recipe3)][0]["points"] = Math.ceil(1.5 * parseInt(this.m_items[parseInt(recipe3)][0]["points"])).toString();
         this.m_items[parseInt(recipe2)][0]["points"] = Math.ceil(1.5 * parseInt(this.m_items[parseInt(recipe2)][0]["points"])).toString();
         this.m_items[parseInt(recipe1)][0]["points"] = Math.ceil(1.5 * parseInt(this.m_items[parseInt(recipe1)][0]["points"])).toString();
         m_sortedSlotData.push(this.m_items[parseInt(recipe3)]);
         m_sortedSlotData.push(this.m_items[parseInt(recipe2)]);
         m_sortedSlotData.push(this.m_items[parseInt(recipe1)]);
         for(i = int(m_sortedSlotData.length - 1); i >= 0; i--)
         {
            m_slotData.push(m_sortedSlotData[i]);
         }
      }
      
      public function setPagination() : void
      {
         this.m_TotalPages = this.getTotalPages();
         if(m_pagingComponent.currentPageNumber == 0)
         {
            this.m_itemHoverTooltip = new FarmTextTooltip(this.SpecialTagInfo);
            this.m_tag0Mc.visible = true;
            this.m_tag0Mc.attachTooltip(this.m_itemHoverTooltip);
            this.m_tag1Mc.visible = true;
            this.m_tag1Mc.attachTooltip(this.m_itemHoverTooltip);
            this.m_tag2Mc.visible = true;
            this.m_tag2Mc.attachTooltip(this.m_itemHoverTooltip);
         }
         this.m_pageTf.text = m_pagingComponent.currentPageNumber + 1 + " " + "of" + " " + this.m_TotalPages;
      }
      
      private function sortByResources(m_slotDataTemp:Array) : Array
      {
         var p:String = null;
         var q:String = null;
         var i:int = 0;
         var j:int = 0;
         var diff1:int = 0;
         var diff2:int = 0;
         var diffa:* = undefined;
         var diffb:* = undefined;
         var diffc:* = undefined;
         var diffd:* = undefined;
         var diffe:* = undefined;
         var difff:* = undefined;
         var temp:Object = null;
         var basicResources:* = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,"53");
         var luxuryResources:* = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,"54");
         var resources:Object = {};
         for(p in basicResources)
         {
            resources[p] = basicResources[p];
         }
         for(q in luxuryResources)
         {
            resources[q] = luxuryResources[q];
         }
         for(i = 0; i < m_slotDataTemp.length - 1; i++)
         {
            for(j = 0; j < m_slotDataTemp.length - i - 1; j++)
            {
               if(m_slotDataTemp[j][0]["re1code"] != "vd5x")
               {
                  diffa = parseInt(m_slotDataTemp[j][0]["re1quant"]) - parseInt(resources[m_slotDataTemp[j][0]["re1code"]]);
               }
               else
               {
                  diffa = 0;
               }
               if(m_slotDataTemp[j + 1][0]["re1code"] != "vd5x")
               {
                  diffb = parseInt(m_slotDataTemp[j + 1][0]["re1quant"]) - parseInt(resources[m_slotDataTemp[j + 1][0]["re1code"]]);
               }
               else
               {
                  diffb = 0;
               }
               if(m_slotDataTemp[j][0]["re2code"] != "vd5x")
               {
                  diffc = parseInt(m_slotDataTemp[j][0]["re2quant"]) - parseInt(resources[m_slotDataTemp[j][0]["re2code"]]);
               }
               else
               {
                  diffc = 0;
               }
               if(m_slotDataTemp[j + 1][0]["re2code"] != "vd5x")
               {
                  diffd = parseInt(m_slotDataTemp[j + 1][0]["re2quant"]) - parseInt(resources[m_slotDataTemp[j + 1][0]["re2code"]]);
               }
               else
               {
                  diffd = 0;
               }
               if(m_slotDataTemp[j][0]["re3code"] != "vd5x")
               {
                  diffe = parseInt(m_slotDataTemp[j][0]["re3quant"]) - parseInt(resources[m_slotDataTemp[j][0]["re3code"]]);
               }
               else
               {
                  diffe = 0;
               }
               if(m_slotDataTemp[j + 1][0]["re3code"] != "vd5x")
               {
                  difff = parseInt(m_slotDataTemp[j + 1][0]["re3quant"]) - parseInt(resources[m_slotDataTemp[j + 1][0]["re3code"]]);
               }
               else
               {
                  difff = 0;
               }
               diff1 = diffa + diffc + diffe;
               diff2 = diffb + diffd + difff;
               if(diffa < diffb && diffc < diffd && diffe < difff)
               {
                  temp = m_slotDataTemp[j];
                  m_slotDataTemp[j] = m_slotDataTemp[j + 1];
                  m_slotDataTemp[j + 1] = temp;
               }
            }
         }
         return m_slotDataTemp;
      }
   }
}

