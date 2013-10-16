#
# This policy configuration will be used by all products that
# inherit from MM
#

BOARD_SEPOLICY_DIRS := \
    vendor/mm/sepolicy

BOARD_SEPOLICY_UNION := \
    mac_permissions.xml
