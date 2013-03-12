CFLAGS += -I$(TOSDIR)/lib/printf 
CFLAGS += -DTOSH_DATA_LENGTH=114 -DSCEN=1 
#CFLAGS += -DDEBUG -DTELOS
#CFLAGS += -DSIM
# For security uncomment line below, though bug exists
# cannot broadcast data
#CFLAGS += -DSECURE -DCC2420_HW_SECURITY -DTFRAMES_ENABLED
COMPONENT=TinyBlogAppC



include $(MAKERULES)
