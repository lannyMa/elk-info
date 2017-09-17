# -*-coding:utf-8-*-

name_list = ['aa', 'bb', 'cc', 'dd', 'ee']
addr_list = ['beijing', 'shanghai', 'guangzhou']
company_list = ['baidu', 'tengxun', 'alibb']

import random
import time


def get_name():
    return name_list[random.randint(0, 4)]


def get_age():
    return random.randint(20, 25)


def get_addr():
    return addr_list[random.randint(0, 2)]


def get_comp():
    return company_list[random.randint(0, 2)]


if __name__ == "__main__":
    while True:
        print("%s %s %s %s" % (get_name(), get_age(), get_addr(), get_comp()))
        str_line = get_name() + " " + str(get_age()) + " " + get_addr() + " " + get_comp()
        import os

        os.system("echo %s >> test1.log" % str_line)
        time.sleep(1)
